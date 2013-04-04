//
//  DLLViewController.m
//  GCDDemo
//
//  Created by Dan Leehr on 4/1/13.
//  Copyright (c) 2013 Dan Leehr LLC. All rights reserved.
//

#import "DLLViewController.h"
static const size_t iterations = 10000000;
static  NSString * const notificationName = @"DLLNotification";
@interface DLLViewController ()

@property (strong, nonatomic) dispatch_source_t source;
@property (nonatomic, assign) unsigned long min;
@property (nonatomic, assign) unsigned long max;
@property (nonatomic, assign) unsigned long count;
@property (strong, nonatomic) NSThread *backgroundThread;
@property (strong, nonatomic) NSRunLoop *runLoop;

@end

@implementation DLLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
    __weak DLLViewController *weakSelf = self;
    dispatch_source_set_event_handler(self.source, ^{
        unsigned long data = dispatch_source_get_data(weakSelf.source);
        weakSelf.count++;
        weakSelf.min = MIN(weakSelf.min, data);
        weakSelf.max = MAX(weakSelf.max, data);
        weakSelf.label.text = [NSString stringWithFormat:@"Min: %ld Max: %ld Count: %ld", weakSelf.min, weakSelf.max, weakSelf.count];
    });
    dispatch_resume(self.source);
    self.backgroundThread = [[NSThread alloc] initWithTarget:self
                                                    selector:@selector(runThread:)
                                                      object:nil];
    [self.backgroundThread start];
}

- (void)runThread:(id)sender {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveNotification:)
                                                 name:notificationName
                                               object:nil];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    while (YES) {
        [runLoop runMode:NSDefaultRunLoopMode
              beforeDate:[NSDate distantFuture]];
    }

}


- (void)didReceiveNotification:(NSNotification *)notification {
    [self performSelectorOnMainThread:@selector(handleNotification:)
                           withObject:notification
                        waitUntilDone:NO];
}

- (void)handleNotification:(NSNotification *)notification {
    int i = [[notification.userInfo objectForKey:@"i"] integerValue];
    int delta = MIN(self.count - i, 0);
    self.min = MIN(self.min, delta);
    self.max = MAX(self.max, delta);
    self.count = i;
    self.label.text = [NSString stringWithFormat:@"Count: %ld", self.count];
}

- (IBAction)dispatchButtonTapped:(id)sender {
    self.min = NSUIntegerMax;
    self.max = 0;
    self.count = 0;
    __weak DLLViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_apply(iterations, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(size_t i) {
            dispatch_source_merge_data(weakSelf.source, 1ull);
        });
    });
}

- (IBAction)notificationButtonTapped:(id)sender {
    self.min = NSUIntegerMax;
    self.max = 0;
    self.count = 0;
    [self performSelector:@selector(postNotification:)
                 onThread:self.backgroundThread
               withObject:nil
            waitUntilDone:NO];
}

- (void)postNotification:(id)sender {
    for (int i=0; i<iterations; i++) {
        
        if (i % 25 == 0) {
            NSNotification *notification = [NSNotification notificationWithName:notificationName
                                                                         object:nil
                                                                       userInfo:@{@"i": @(i)}];
            [[NSNotificationQueue defaultQueue] enqueueNotification:notification
                                                       postingStyle:NSPostNow
                                                       coalesceMask:NSNotificationCoalescingOnName
                                                           forModes:nil];
        }
    }
}

- (void)dealloc {
    dispatch_source_cancel(self.source);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

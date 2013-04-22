GCDDemo
=======

A demonstration of dispatch_source_merge_data vs NSNotification

This app runs 10 million operations to demonstrate UI progress updates with GCD's dispatch_source_merge_data, as compared with posting an NSNotification from a dedicated background thread with an NSRunLoop.

My NSRunLoop skills aren't bulletproof, but the NSNotification version basically locks up the UI, even when only notifying on 1 out of every 25 operations

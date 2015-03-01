//
//  BackgroundDownloadController.m
//  BaiduAPI
//
//  Created by 赵立波 on 15/2/25.
//  Copyright (c) 2015年 赵立波. All rights reserved.
//

#import "BackgroundDownloadController.h"

#import "AppDelegate.h"

@interface BackgroundDownloadController () <NSURLSessionDelegate,NSURLSessionTaskDelegate,NSURLSessionDownloadDelegate,UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic,strong) UIDocumentInteractionController *documentInteractionController;

@end

static NSString *DownloadURLString = @"http://www.youwandao.com/uploads/package/63.zip";

@implementation BackgroundDownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.progressView.progress=0.f;
    self.progressLabel.text=@"0.0%";
    
    self.session=[self backgroundSession];
    
}

-(NSURLSession *)backgroundSession {
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.example.apple-samplecode.SimpleBackgroundTransfer.BackgroundSession"];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
    return session;
}

- (IBAction)startDownload:(id)sender {
    if (self.downloadTask) {
        return;
    }
    NSURL *downloadURL = [NSURL URLWithString:DownloadURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask resume];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (downloadTask == self.downloadTask) {
        double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        NSLog(@"DownloadTask: %@ progress: %lf", downloadTask, progress);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress;
            self.progressLabel.text=[NSString stringWithFormat:@"%.2f%%",progress*100];
        });
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)downloadURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [URLs objectAtIndex:0];
    NSURL *originalURL = [[downloadTask originalRequest] URL];
    NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
    NSError *errorCopy;
    // For the purposes of testing, remove any esisting file at the destination.
    [fileManager removeItemAtURL:destinationURL error:NULL];
    BOOL success = [fileManager copyItemAtURL:downloadURL toURL:destinationURL error:&errorCopy];
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //download finished - open the pdf
            self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:destinationURL];
            // Configure Document Interaction Controller
            [self.documentInteractionController setDelegate:self];
            // Preview PDF
            [self.documentInteractionController presentPreviewAnimated:YES];
            self.progressView.hidden = YES;
        });
    } else {
        NSLog(@"Error during the copy: %@", [errorCopy localizedDescription]);
    }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error == nil) {
        NSLog(@"Task: %@ completed successfully", task);
    } else {
        NSLog(@"Task: %@ completed with error: %@", task, [error localizedDescription]);
    }
    double progress = (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = progress;
    });
    self.downloadTask = nil;
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    NSLog(@"All tasks are finished");
}
@end

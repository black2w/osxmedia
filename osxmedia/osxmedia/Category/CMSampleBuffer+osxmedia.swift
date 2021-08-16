//
//  CMSampleBuffer+osxmedia.swift
//  osxmedia
//
//  Created by black2w on 2021/8/12.
//

import AVFoundation


extension CMSampleBuffer {

    /// Creates an offset `CMSampleBuffer` for the given time offset and duration.
    ///
    /// - Parameters:
    ///   - sampleBuffer: Input sample buffer to copy and offset.
    ///   - timeOffset: Time offset for the output sample buffer.
    ///   - duration: Optional duration for the output sample buffer.
    /// - Returns: Sample buffer with the desired time offset and duration, otherwise nil.
    public class func createSampleBuffer(fromSampleBuffer sampleBuffer: CMSampleBuffer, withTimeOffset timeOffset: CMTime, duration: CMTime?) -> CMSampleBuffer? {
        var itemCount: CMItemCount = 0
        var status = CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, entryCount: 0, arrayToFill: nil, entriesNeededOut: &itemCount)
        if status != 0 {
            return nil
        }

        var timingInfo = [CMSampleTimingInfo](repeating: CMSampleTimingInfo(duration: CMTimeMake(value: 0, timescale: 0), presentationTimeStamp: CMTimeMake(value: 0, timescale: 0), decodeTimeStamp: CMTimeMake(value: 0, timescale: 0)), count: itemCount)
        status = CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, entryCount: itemCount, arrayToFill: &timingInfo, entriesNeededOut: &itemCount)
        if status != 0 {
            return nil
        }

        if let dur = duration {
            for i in 0 ..< itemCount {
                timingInfo[i].decodeTimeStamp = CMTimeSubtract(timingInfo[i].decodeTimeStamp, timeOffset)
                timingInfo[i].presentationTimeStamp = CMTimeSubtract(timingInfo[i].presentationTimeStamp, timeOffset)
                timingInfo[i].duration = dur
            }
        } else {
            for i in 0 ..< itemCount {
                timingInfo[i].decodeTimeStamp = CMTimeSubtract(timingInfo[i].decodeTimeStamp, timeOffset)
                timingInfo[i].presentationTimeStamp = CMTimeSubtract(timingInfo[i].presentationTimeStamp, timeOffset)
            }
        }

        var sampleBufferOffset: CMSampleBuffer?
        CMSampleBufferCreateCopyWithNewTiming(allocator: kCFAllocatorDefault, sampleBuffer: sampleBuffer, sampleTimingEntryCount: itemCount, sampleTimingArray: &timingInfo, sampleBufferOut: &sampleBufferOffset)

        if let output = sampleBufferOffset {
            return output
        } else {
            return nil
        }
    }

}

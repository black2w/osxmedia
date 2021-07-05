# osxmedia
1，获取设备列表
2，根据设备设置AVCaptureDeviceInput、AVCaptureVideoDataOutput
3，实现output的委托
4，采集

notic:
切换设备时 
self.avSession.removeOutput(self.videoOutput)
self.avSession.removeInput(self.videoInput)


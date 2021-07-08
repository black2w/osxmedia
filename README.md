# osxmedia
1. 获取设备列表
2. 根据设备设置AVCaptureDeviceInput、AVCaptureVideoDataOutput
3. 实现output的委托
4. 采集
5. 尺寸的常量实现定义
6. 设备的类需要完善

- notice:
- 切换设备时 
- self.avSession.removeOutput(self.videoOutput)
- self.avSession.removeInput(self.videoInput)
- 加载NSViewController时，不能自动capture(怀疑与preview的Bounds有关，目前采用延时调用的方式实现。need fix)

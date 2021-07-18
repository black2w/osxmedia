# osxmedia
1. 获取设备列表
2. 根据设备设置AVCaptureDeviceInput、AVCaptureVideoDataOutput
3. 实现output的委托
4. 采集
5. 尺寸的常量实现定义
6. 设备的类需要完善
7. 抽象出设备类，目前属性暂定。根据screen和capturedevice区分是摄像头还是屏幕。按照设想应该是一个input的抽象类，然后根据设备做具体实体。由于avcapturepreview的限制，暂未想到更好的方法。需继续完善
8. 截图的时候，还可以根据vc进行。目前方法较复杂。可以添加更好的方法

- notice:
- 切换设备时 
- self.avSession.removeOutput(self.videoOutput)
- self.avSession.removeInput(self.videoInput)
- 加载NSViewController时，不能自动capture(怀疑与preview的Bounds有关，目前采用延时调用的方式实现。need fix)

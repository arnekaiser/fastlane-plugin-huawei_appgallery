describe Fastlane::Actions::HuaweiAppgalleryAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The huawei_appgallery plugin is working!")

      Fastlane::Actions::HuaweiAppgalleryAction.run(nil)
    end
  end
end

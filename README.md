# huawei_appgallery plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-huawei_appgallery)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-huawei_appgallery`, add it to your project by running:

```bash
fastlane add_plugin huawei_appgallery
```

## About huawei_appgallery

Plugin to deploy an app to the Huawei AppGallery. Updates the release notes, uploads an APK and submits the new version for review.

**Note:** To authenticate, you need to create the signature by your own. 
Example code: https://developer.huawei.com/consumer/en/service/hms/catalog/publishingAPI.html?page=hmssdk_appGalleryConnect_devguide (Authentication by secret key)

Pull requests are welcome. ;)

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin.

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).

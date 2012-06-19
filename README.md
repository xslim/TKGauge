# TKGauge

iOS UI component to display gauge

## Installation

* You need [cocoapods](http://cocoapods.org) lib manager
* Edit your `Podfile` and add

```ruby
dependency 'TKGauge', :podspec => 'https://raw.github.com/xslim/TKGauge/master/TKGauge.podspec'
```


## Usage

* See Example project

![1](https://github.com/xslim/TKGauge/raw/master/screenshots/1.png)

### Loading Gauge

```obj-c
NSString *path = [[NSBundle mainBundle] bundlePath];
self.gaugePath = [[path stringByAppendingPathComponent:@"Gauges"] stringByAppendingPathComponent:@"speed.gauge"];
```

### Data filter

* By default, data filter `maxAverageCount` will be loaded from skin's config `config.averageFilter` - TODO
* To turn off data filter just say `self.dataFilter.maxAverageCount = 0;` (Ex. some where in `viewDidLoad`)

## Theaming
* See Gauges folder

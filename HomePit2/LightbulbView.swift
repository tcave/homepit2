//
//  LightbulbCell.swift
//  HomePit2
//
//  Created by John Grosen on 6/30/14.
//  Copyright (c) 2014 John Grosen. All rights reserved.
//

import UIKit
import HomeKit

func genLineConstraints(label: UILabel, control: UIControl) -> AnyObject[]! {
    let viewsDict = ["label": label, "control": control]
    return NSLayoutConstraint.constraintsWithVisualFormat(LINE_LAYOUT, options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDict)
}

extension HMService {
    func findCharacteristic(name: String) -> HMCharacteristic? {
        for cha in self.characteristics as HMCharacteristic[] {
            if cha.characteristicType == name {
                return cha
            }
        }
        return nil
    }
}

extension UISlider {
    convenience init(min: CFloat, max: CFloat) {
        self.init()
        self.minimumValue = min
        self.maximumValue = max
        // self.setTranslatesAutoresizingMaskIntoConstraints(false)
    }
}

let MARGIN: CGFloat = 10
let LABEL_HEIGHT: CGFloat = 30
let SLIDER_HEIGHT: CGFloat = 30
let SWITCH_HEIGHT: CGFloat = 30

let LINE_LAYOUT: String = "H:|-[label]-[control(==label)]"
let VERT_LAYOUT: String = "V:|-[name]-[hue]-[saturation]-[brightness]-[power]-|"

extension UILabel {
    convenience init(text: String, align: NSTextAlignment) {
        self.init()
        self.text = text
        self.textAlignment = align
    }
}

class LightbulbView: UIScrollView, ServiceDelegate {

    var nameLabel: UILabel
    var hueLabel: UILabel
    var hueSlider: UISlider
    var saturationLabel: UILabel
    var saturationSlider: UISlider
    var brightnessLabel: UILabel
    var brightnessSlider: UISlider
    var powerLabel: UILabel
    var powerSwitch: UISwitch
    
    var service: HMService
    
    init(frame: CGRect, service: HMService) {
        self.nameLabel = UILabel(text: service.name, align: .Left)

        self.hueLabel = UILabel(text: "Hue", align: .Right)
        self.hueSlider = UISlider(min: 0, max: 360)
        self.saturationLabel = UILabel(text: "Saturation", align: .Right)
        self.saturationSlider = UISlider(min: 0, max: 100)
        self.brightnessLabel = UILabel(text: "Brightness", align: .Right)
        self.brightnessSlider = UISlider(min: 0, max: 100)
        
        self.powerLabel = UILabel(text: "Power", align: .Right)
        self.powerSwitch = UISwitch()
        //self.powerSwitch.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.service = service
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        
        self.addSubview(self.nameLabel)
        self.addSubview(self.hueLabel)
        self.addSubview(self.hueSlider)
        self.addSubview(self.saturationLabel)
        self.addSubview(self.saturationSlider)
        self.addSubview(self.brightnessLabel)
        self.addSubview(self.brightnessSlider)
        self.addSubview(self.powerLabel)
        self.addSubview(self.powerSwitch)
        
        self.hueSlider.addTarget(self, action: Selector("hueChanged:"), forControlEvents: .ValueChanged)
        self.saturationSlider.addTarget(self, action: Selector("saturationChanged:"), forControlEvents: .ValueChanged)
        self.brightnessSlider.addTarget(self, action: Selector("brightnessChanged:"), forControlEvents: .ValueChanged)
        self.powerSwitch.addTarget(self, action: Selector("powerChanged:"), forControlEvents: .ValueChanged)
        
        let things: [(String, UILabel, UISlider)] = [("public.hap.characteristic.hue", self.hueLabel, self.hueSlider),
            ("public.hap.characteristic.saturation", self.saturationLabel, self.saturationSlider),
            ("public.hap.characteristic.brightness", self.brightnessLabel, self.brightnessSlider)]
        
        for (chaName, label, control) in things {
            if let cha = service.findCharacteristic(chaName) {
                cha.enableNotification(true, completionHandler: { _ in })
                control.value = cha.value as Float
            } else {
                label.enabled = false
                control.enabled = false
            }
        }
        
        
        if let powerCha = service.findCharacteristic("public.hap.characteristic.on") {
            powerCha.enableNotification(true, completionHandler: { _ in })
            self.powerSwitch.on = powerCha.value as Bool
        } else {
            self.powerLabel.enabled = false
            self.powerSwitch.enabled = false
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // self.setTranslatesAutoresizingMaskIntoConstraints(false)
        //println(self.frame)
        
        /*
        
        self.addConstraints(genLineConstraints(self.hueLabel, self.hueSlider))
        self.addConstraints(genLineConstraints(self.saturationLabel, self.saturationSlider))
        self.addConstraints(genLineConstraints(self.brightnessLabel, self.brightnessSlider))
        self.addConstraints(genLineConstraints(self.powerLabel, self.powerSwitch))

        let allViewsDict = ["name": self.nameLabel, "hue": self.hueLabel, "saturation": self.saturationLabel, "brightness": self.brightnessLabel, "power": self.powerLabel]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(VERT_LAYOUT, options: NSLayoutFormatOptions(0), metrics: nil, views: allViewsDict))
        
        */
        

        let (width, height) = (self.bounds.size.width, self.bounds.size.height)
        let controlWidth = width / 2

        self.nameLabel.frame = CGRect(x: MARGIN, y: MARGIN, width: width - 2*MARGIN, height: LABEL_HEIGHT)

        self.hueLabel.frame = CGRect(x: MARGIN, y: 2*MARGIN + LABEL_HEIGHT, width: controlWidth - 2*MARGIN, height: SLIDER_HEIGHT)
        self.hueSlider.frame = CGRect(x: controlWidth + MARGIN, y: 2*MARGIN + LABEL_HEIGHT, width: controlWidth - 2*MARGIN, height: SLIDER_HEIGHT)

        self.saturationLabel.frame = CGRect(x: MARGIN, y: 3*MARGIN + LABEL_HEIGHT + SLIDER_HEIGHT, width: controlWidth - 2*MARGIN, height: SLIDER_HEIGHT)
        self.saturationSlider.frame = CGRect(x: controlWidth + MARGIN, y: 3*MARGIN + LABEL_HEIGHT + SLIDER_HEIGHT, width: controlWidth - 2*MARGIN, height: SLIDER_HEIGHT)

        self.brightnessLabel.frame = CGRect(x: MARGIN, y: 4*MARGIN + LABEL_HEIGHT + 2*SLIDER_HEIGHT, width: controlWidth - 2*MARGIN, height: SLIDER_HEIGHT)
        self.brightnessSlider.frame = CGRect(x: controlWidth + MARGIN, y: 4*MARGIN + LABEL_HEIGHT + 2*SLIDER_HEIGHT, width: controlWidth - 2*MARGIN, height: SLIDER_HEIGHT)

        self.powerLabel.frame = CGRect(x: MARGIN, y: 5*MARGIN + LABEL_HEIGHT + 3*SLIDER_HEIGHT, width: controlWidth - 2*MARGIN, height: SWITCH_HEIGHT)
        self.powerSwitch.frame = CGRect(x: controlWidth + MARGIN, y: 5*MARGIN + LABEL_HEIGHT + 3*SLIDER_HEIGHT, width: controlWidth - 2*MARGIN, height: SWITCH_HEIGHT)

    }
    
    func hueChanged(slider: UISlider) {
        let cha: HMCharacteristic? = self.service.findCharacteristic("public.hap.characteristic.hue")
        cha?.writeValue(Int(round(slider.value)), { _ in })
    }
    
    func saturationChanged(slider: UISlider) {
        let cha = self.service.findCharacteristic("public.hap.characteristic.saturation")
        cha?.writeValue(Int(round(slider.value)), { _ in })
    }
    
    func brightnessChanged(slider: UISlider) {
        let cha = self.service.findCharacteristic("public.hap.characteristic.brightness")
        cha?.writeValue(Int(round(slider.value)), { _ in })
    }
    
    func powerChanged(switch_: UISwitch) {
        let cha = self.service.findCharacteristic("public.hap.characteristic.on")
        cha?.writeValue(switch_.on  , { _ in })
    }
    
    func characteristicValueDidChange(cha: HMCharacteristic) {
        println("characteristic value changed")
    }
    
    func serviceNameDidChange() {
        self.nameLabel.text = self.service.name
    }
    
}

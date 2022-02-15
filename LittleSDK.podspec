Pod::Spec.new do |spec|
  spec.name         = 'LittleSDK'
  spec.version      = '1.0.1'
  spec.authors      = { 
    'Gabriel John' => 'john.gachuhi@little.africa',
    'Erick Karani' => 'eric.karani@little.africa'
  }
  spec.license      = { 
    :type => 'MIT',
    :file => 'LICENSE' 
  }
  spec.homepage     = 'https://github.com/littleappdevs/littleapp'
  spec.source       = { 
    :git => 'https://github.com/littleappdevs/littleapp.git', 
    :branch => 'master',
    :tag => spec.version.to_s 
  }
  spec.summary      = 'This is a Library to access some of the Little Apps features including Ride hailing, Payments and Deliveries'
  spec.source_files = '**/*.swift', '*.swift'
  spec.swift_versions = '5.0'
  spec.ios.deployment_target = '11.0'
end
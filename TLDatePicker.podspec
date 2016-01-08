Pod::Spec.new do |s|
  s.name         = "TLDatePicker"
  s.version      = "0.0.1"
  s.summary      = "Date Picker popup."

  s.homepage     = "https://github.com/ludoded/TLDatePicker"
  s.license      = "MIT"
  s.author             = { "Haik" => "haik.ampardjian@gmail.com" }
  s.platform     = :ios, "8.0"
  s.requires_arc = true
  s.framework    = 'UIKit'
  s.source       = { :git => "https://github.com/ludoded/TLDatePicker.git", :tag => "0.0.1" }

  s.source_files  = "TLDatePicker/DatePicker/*.{h,m}"
  s.resources = "TLDatePicker/DatePicker/Resources/*.png"
  s.dependency "FSCalendar"

end

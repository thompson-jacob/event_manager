require 'csv'
require 'erb'
require 'google/apis/civicinfo_v2'
require 'date'


def clean_zipcode(zip)
  zip.to_s.rjust(5,'0')[0...5]
end 

def clean_phone(phone)
 phone = phone.gsub(/[^0-9]+/, '')
 return phone if phone.length == 10 
 return "No Number" if phone.length < 10

  if phone.length == 11 
    if phone[0] == "1"
      return phone[1..10]
    else
      return  "No Number"
    end
  else
    return  "No Number"
  end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zip, 
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end



puts "Event Manager Initialized!"

template_letter = File.read('form_letter.erb')
erb_template =  ERB.new(template_letter)

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol,
)
day_of_week_registered = []
hours_registered = []
contents.each do |row|
  id = row[0]
  f_name = row[:first_name]
  phone = row[:homephone]
  date_time = row[:regdate]
  date_time = DateTime.strptime(date_time, "%m/%d/%y %H:%M")
  
  day_of_week_registered << date_time.wday
  hours_registered << date_time.hour
  phone = clean_phone(phone)
  zip = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zip)
  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)
end





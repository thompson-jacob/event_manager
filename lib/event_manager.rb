require 'csv'
require 'google/apis/civicinfo_v2'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

response = civic_info.representative_info_by_address(address: 20010, levels: 'country', roles: ['legislatorUpperBody', 'legislatorLowerBody'])
pp response.officials

puts "Event Manager Initialized!"

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol,
)

# def clean_zipcode(zip)
#   if zip.nil?
#     zip = "00000"
#   elsif zip.length > 5
#     zip = zip[0...5]
#   elsif zip.length < 5
#     zip = zip.rjust(5,'0')
#   else
#     zip
#   end
# end 

def clean_zipcode(zip)
  zip.to_s.rjust(5,'0')[0...5]
end 


contents.each do |row|
  f_name = row[:first_name]
  zip = clean_zipcode(row[:zipcode])
  # puts "#{f_name} #{zip}"
end

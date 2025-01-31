FactoryBot.define do
  factory :contact do
    name { "Test User" }
    email { "test@test.com" }
    message { "This is a test." }
    phone { "(800) 555-1212" }
    submit_information { "The contacts information was successfully sent." }
  end
end

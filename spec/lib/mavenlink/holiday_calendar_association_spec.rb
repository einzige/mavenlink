require "spec_helper"

describe Mavenlink::HolidayCalendarAssociation, type: :model do
  describe "associations" do
    it { is_expected.to respond_to :holiday }
    it { is_expected.to respond_to :holiday_calendar }
  end
end

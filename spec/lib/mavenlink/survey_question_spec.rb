require "spec_helper"

describe Mavenlink::SurveyQuestion, stub_requests: true do
  it_should_behave_like "model", "survey_questions"

  describe "validations" do
    it { should validate_presence_of :text }
    it { should validate_presence_of :question_type }
  end

  describe "associations" do
    it { should respond_to :choices }
  end
end
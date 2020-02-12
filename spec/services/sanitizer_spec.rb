require "rails_helper"

RSpec.describe Sanitizer, type: :service do
  describe "sanitizer" do
    context "links" do
      it "removes links" do
        input1 = "check out <a href='https://rubygems.org'>ruby gems</a>"
        expect(Sanitizer.sanitize(input1)).to eq "check out ruby gems"

        input2 = "email me at <a href='mailto:test@test.co.nz'>tesst@test.co.nz</a>"
        expect(Sanitizer.sanitize(input2)).to eq "email me at tesst@test.co.nz"

        input3 = "check my <a href='http://test.blog.co.nz/' class='nav' target='_blank'>test blog</a>"
        expect(Sanitizer.sanitize(input3)).to eq "check my test blog"
      end
    end

    context "tags" do
      it "removes tags" do
        input1 = "strip <i>these</i> tags!"
        expect(Sanitizer.sanitize(input1)).to eq "strip these tags!"

        input2 = "<b>bold</b> no more! <a href='more.html'>see more here</a> ..."
        expect(Sanitizer.sanitize(input2)).to eq "bold no more! see more here ..."

        input3 = "<div id='top-bar'>welcome to this test!</div>"
        expect(Sanitizer.sanitize(input3)).to eq "welcome to this test!"

        input3 = "<p>nice input field<script>alert('and open to xss attacks')</script></p>"
        expect(Sanitizer.sanitize(input3)).to eq "nice input fieldalert('and open to xss attacks')"
      end
    end
  end
end

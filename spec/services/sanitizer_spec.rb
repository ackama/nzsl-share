require "rails_helper"

RSpec.describe Sanitizer, type: :service do
  describe ".sanitize" do
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

  describe ".sanitize_text_with_urls" do
    context "schema" do
      it "accepts http" do
        input = "check this http://rubygems.org"
        expect(Sanitizer.sanitize_text_with_urls(input)).to eq input
      end

      it "accepts https" do
        input = "text this https://rubygems.org"
        expect(Sanitizer.sanitize_text_with_urls(input)).to eq input
      end

      it "does not accept unsupported schema" do
        input1 = "check this hppt://rubygems.org"
        expect(Sanitizer.sanitize_text_with_urls(input1)).to eq "check this "

        input2 = "check this ftp://test@rubygems.org"
        expect(Sanitizer.sanitize_text_with_urls(input2)).to eq "check this "
      end
    end
  end

  describe ".sanitize_urls" do
    context "encoded" do
      it "decodes a url without a query string" do
        input1 = "https%3A%2F%2Frubygems.org"
        expect(Sanitizer.sanitize_url(input1)).to eq "https://rubygems.org"

        input2 = "https%3A%2F%2Frubygems.org%2Fgems%2Fapi-pagination"
        expect(Sanitizer.sanitize_url(input2)).to eq "https://rubygems.org/gems/api-pagination"

        input3 = "https://rubygems.org"
        expect(Sanitizer.sanitize_url(input3)).to eq "https://rubygems.org"
      end

      it "encodes only the query string of a url" do
        input1 = "https://rubygems.org/search?query=pagination"
        expect(Sanitizer.sanitize_url(input1)).to eq "https://rubygems.org/search?query%3Dpagination"

        input2 = "https%3A%2F%2Frubygems.org%2Fsearch%3Fquery%3Dpagination"
        expect(Sanitizer.sanitize_url(input2)).to eq "https://rubygems.org/search?query%3Dpagination"
      end

      it "removes tags that are not encoded" do
        xss = "http://localhost/weak-site/search?keyword=<script>window.location="\
              "'http://localhost/?victimcookie='+document.cookie</script>"

        clean_url = Sanitizer.sanitize_url(xss)

        expect(CGI.unescape(clean_url)).to eq "http://localhost/weak-site/search?keyword=window.location="\
                                              "'http://localhost/?victimcookie=' document.cookie"
      end

      it "removes tags that are encoded" do
        xss = "http%3A%2F%2Flocalhost%2Fweak-site%2Fsearch%3Fkeyword%3D%3Cscript%3Ewindow."\
              "location%3D%27http%3A%2F%2Flocalhost%2F%3Fvictimcookie%3D%27%2Bdocument.cookie%3C%2Fscript%3E"

        expect(Sanitizer.sanitize_url(xss)).to eq "http://localhost/weak-site/search?keyword%3Dwindow."\
                                                  "location%3D%27http%3A%2F%2Flocalhost%2F%3Fvictimcookie%3D%27+"\
                                                  "document.cookie"
      end
    end
  end
end

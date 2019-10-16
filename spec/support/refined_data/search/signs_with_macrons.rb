module Refined
  module Search
    module Signs
      module_function

      def with_macrons
        dt = DateTime.now
        [
          {
            english: "āporo",
            maori: "āporo",
            secondary: "apple, pie, america, cream",
            published_at: dt
          },
          {
            english: "rahopūru",
            maori: "rahopūru",
            secondary: "avocado, guacamole, mexico, dip, toast",
            published_at: dt - 2.days
          },
          {
            english: "pīti",
            maori: "pīti",
            secondary: "beetroot, soup, borscht, russia, risotto, italy",
            published_at: dt - 4.days
          },
          {
            english: "kihu parāoa",
            maori: "kihu parāoa",
            secondary: "noodles, china, japan",
            published_at: dt - 8.days
          }
        ]
      end
    end
  end
end

module Refined
  module Search
    module Signs
      module_function

      def with_macrons
        dt = DateTime.now
        [
          {
            word: "āporo",
            maori: "āporo",
            secondary: "apple, pie, america, cream",
            published_at: dt
          },
          {
            word: "rahopūru",
            maori: "rahopūru",
            secondary: "avocado, guacamole, mexico, dip, toast",
            published_at: dt - 2.days
          },
          {
            word: "pīti",
            maori: "pīti",
            secondary: "beetroot, soup, borscht, russia, risotto, italy",
            published_at: dt - 4.days
          },
          {
            word: "kihu parāoa",
            maori: "kihu parāoa",
            secondary: "noodles, china, japan",
            published_at: dt - 8.days
          }
        ]
      end
    end
  end
end

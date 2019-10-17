module Refined
  module Search
    module Signs
      module_function

      def default
        dt = DateTime.now
        [
          {
            word: "apple",
            maori: "āporo",
            secondary: "pie, america, cream",
            published_at: dt
          },
          {
            word: "apricot",
            maori: "aperekoti",
            secondary: "pie, jam, england, cream",
            published_at: dt - 1.day
          },
          {
            word: "asparagus",
            maori: "apareka",
            secondary: "hollandaise, france, eggs, soup, risotto, italy",
            published_at: dt - 2.days
          },
          {
            word: "avocado",
            maori: "rahopūru",
            secondary: "guacamole, mexico, dip, toast",
            published_at: dt - 3.days
          },
          {
            word: "banana",
            maori: "panana",
            secondary: "banoffee, pie, england, chocolate, america",
            published_at: dt - 4.days
          },
          {
            word: "beetroot",
            maori: "pīti",
            secondary: "soup, borscht, russia, risotto, italy",
            published_at: dt - 5.days
          },
          {
            word: "blueberry",
            maori: "patatini kikorang",
            secondary: "muffin, america, smothie",
            published_at: dt - 6.days
          }
        ]
      end
    end
  end
end

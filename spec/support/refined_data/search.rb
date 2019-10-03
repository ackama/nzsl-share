module Refined
  module Search
    module Data
      module_function

      def signs
        dt = DateTime.now
        [
          {
            english: "apple",
            maori: "āporo",
            secondary: "pie, america, cream",
            published_at: dt
          },
          {
            english: "apricot",
            maori: "aperekoti",
            secondary: "pie, jam, england, cream",
            published_at: dt - 1.day
          },
          {
            english: "asparagus",
            maori: "apareka",
            secondary: "hollandaise, france, eggs, soup, risotto, italy",
            published_at: dt - 2.days
          },
          {
            english: "avocado",
            maori: "rahopūru",
            secondary: "guacamole, mexico, dip, toast",
            published_at: dt - 3.days
          },
          {
            english: "banana",
            maori: "panana",
            secondary: "banoffee, pie, england, chocolate, america",
            published_at: dt - 4.days
          },
          {
            english: "beetroot",
            maori: "pīti",
            secondary: "soup, borscht, russia, risotto, italy",
            published_at: dt - 5.days
          },
          {
            english: "blueberry",
            maori: "patatini kikorang",
            secondary: "muffin, america, smothie",
            published_at: dt - 6.days
          }
        ]
      end
    end
  end
end

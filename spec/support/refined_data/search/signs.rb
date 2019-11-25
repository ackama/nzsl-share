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
            published_at: dt,
            status: "published",
            conditions_accepted: true
          },
          {
            word: "apricot",
            maori: "aperekoti",
            secondary: "pie, jam, england, cream",
            published_at: dt - 1.day,
            status: "published",
            conditions_accepted: true
          },
          {
            word: "asparagus",
            maori: "apareka",
            secondary: "hollandaise, france, eggs, soup, risotto, italy",
            published_at: dt - 2.days,
            status: "published",
            conditions_accepted: true
          },
          {
            word: "avocado",
            maori: "rahopūru",
            secondary: "guacamole, mexico, dip, toast",
            published_at: dt - 3.days,
            status: "published",
            conditions_accepted: true
          },
          {
            word: "banana",
            maori: "panana",
            secondary: "banoffee, pie, england, chocolate, america",
            published_at: dt - 4.days,
            status: "published",
            conditions_accepted: true
          },
          {
            word: "beetroot",
            maori: "pīti",
            secondary: "soup, borscht, russia, risotto, italy",
            published_at: dt - 5.days,
            status: "published",
            conditions_accepted: true
          },
          {
            word: "blueberry",
            maori: "patatini kikorang",
            secondary: "muffin, america, smothie",
            published_at: dt - 6.days,
            status: "published",
            conditions_accepted: true
          }
        ]
      end
    end
  end
end

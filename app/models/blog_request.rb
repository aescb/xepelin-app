class BlogRequest < ApplicationRecord
  enum category: { all_categories: 0, pymes: 1, xepelin: 2, corporatives: 3, financial_education: 4, entrepreneurs: 5, success_cases: 6 }
end

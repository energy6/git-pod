require 'ramcrest'

module Ramcrest  
  module MatchesPattern
    include Ramcrest::SuchThat

    def matches_pattern(pattern)
      such_that("a string matches /#{pattern}/") do |actual|
        actual =~ pattern ? success : mismatch("pattern does not match")
      end
    end
  end
end

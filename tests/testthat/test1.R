test_that("invalid inputs",
         {expect_that(fars_read(2050),throws_error())
          expect_that(fars_read_years(2050),gives_warning())
          expect_that(fars_map_state(100,2013),throws_error())
        })

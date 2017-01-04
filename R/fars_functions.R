#' Read file
#'
#' This is a function which reads the FARS data from a csv file
#' into a dataframe and converts it into a tbl_df object
#'
#' @param filename A character string which is the name of the csv file
#'    with the FARS data
#'
#' @return This function returns the FARS data in a tbl_df object
#'
#' @note If the filename does not exist, the function stops with an
#'    error message.
#'
#' @importFrom readr read_csv
#' @importFrom dplyr tbl_df
#'
#' @examples
#' filename<-system.file("extdata","accident_2013.csv.bz2",package="FARSanalysis")
#' fars_read(filename)
#'
#' @export
fars_read <- function(filename) {

        if(!file.exists(filename))
                stop("file '", filename, "' does not exist")
        data <- suppressMessages({
                readr::read_csv(filename, progress = FALSE)
        })
        dplyr::tbl_df(data)
}

#' Make filename
#'
#' This function returns a filename based on the year of the accident data.
#'
#' @param year Integer corresponding to the year of the FARS accident data.
#'
#' @return This function returns a character string containing the filename
#'    of the accident data for a particular year.
#'
#' @examples
#' make_filename(2013)
#'
#' @export
make_filename <- function(year) {
        year <- as.integer(year)
        sprintf("accident_%d.csv.bz2", year)
}

#' Select month and year data from files corresponding to a list of years.
#'
#' This function returns the MONTH and year data from each file from a list of
#' input files corresponding to a list of years.
#'
#' @param years A integer for a single year or a vector of integers for a list of years.
#'
#' @return This function returns the MONTH and year data from a file for each year
#'    in the input list.  The data is returned as a list where each list item
#'    is a tbl_df object containing MONTH and year data for one file.
#'
#' @note This function returns an error if an invalid year is present
#'    in the input list.  An invalid year is one where the filename for that
#'    year does not exist.
#'
#' @importFrom dplyr mutate select
#' @import magrittr
#'
#' @examples
#' \dontrun{
#' fars_read_years(2013)
#' fars_read_years(c(2013,2014))
#' }
#'
#' @export
fars_read_years <- function(years) {
        lapply(years, function(year) {
                file <- make_filename(year)
                tryCatch({
                        dat <- fars_read(file)
                        dplyr::mutate_(dat, year = year) %>%
                                dplyr::select_(.dots=c('MONTH', 'year'))
                }, error = function(e) {
                        warning("invalid year: ", year)
                        return(NULL)
                })
        })
}

#' Summarize number of accidents per month of a year
#'
#' This function returns the number of accidents grouped by MONTH and year for
#' a given number of years.
#'
#' @param years A integer for a single year or a vector of integers for a list of years.
#'
#' @return This function returns the number of FARS accidents grouped by MONTH and year.
#' The data is returned as a tbl_df with a MONTH column followed by a
#' column corresponding to each year in the input list.
#'
#' @importFrom dplyr bind_rows group_by summarize
#' @importFrom tidyr spread
#' @import magrittr
#'
#' @examples
#' \dontrun{
#' fars_summarize_years(2013)
#' fars_summarize_years(c(2013,2014))
#' }
#'
#' @export
fars_summarize_years <- function(years) {
        dat_list <- fars_read_years(years)
        dplyr::bind_rows(dat_list) %>%
                dplyr::group_by_(~year, ~MONTH) %>%
                dplyr::summarize_(n = ~ n()) %>%
                tidyr::spread_(key_col = 'year', value_col = 'n')
}

#' Display a map of a state with the accidents plotted on the map
#'
#' This function creates a figure of a state map.  The points on the
#' map correspond to accidents in the FARS data.  Each accident is plotted
#' according to the latitude and longitude of the accident site.
#'
#' @param state.num An integer representing the number of a state as defined in the FARS data.
#' @param year An integer corresponding to the year of the FARS accident data.
#'
#' @return A figure of a state map with accidents plotted by geographic location
#'    as specified by latitude and longitude is printed.
#'
#' @note If an invalid state number is used as input, the function stops with an
#'    error message.
#'
#' @note If there are zero accidents for a particular state and year, a message
#'    is displayed and the function ends.
#'
#' @importFrom dplyr filter
#' @importFrom maps map
#' @importFrom graphics points
#'
#'
#' @examples
#' \dontrun{
#' fars_map_state(1,2013)
#' }
#'
#' @export
fars_map_state <- function(state.num, year) {
        filename <- make_filename(year)
        data <- fars_read(filename)
        state.num <- as.integer(state.num)

        if(!(state.num %in% unique(data$STATE)))
                stop("invalid STATE number: ", state.num)
        data.sub <- dplyr::filter_(data, ~ STATE == state.num)
        if(nrow(data.sub) == 0L) {
                message("no accidents to plot")
                return(invisible(NULL))
        }
        is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
        is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
        with(data.sub, {
                maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
                          xlim = range(LONGITUD, na.rm = TRUE))
                graphics::points(LONGITUD, LATITUDE, pch = 46)
        })
}

#' Find alternative products for all products containing a certain active substance in PSM-V
#'
#'This function creates two overview tables
#'1) tbl_overview_culture_pest:
#'Indicates for the active ingredient(s) searched for, in which crops and against which pathogens
#'products with the active ingredient searched for are authorised.
#'In addition, the column "number_alternative_products" indicates how many
#'authorised alternative products (without the active substances searched for)
#'are authorised for the crop-pathogen combination. The following columns show
#'the number of authorised products (based on the W number) with the active substance(s) searched for.
#'2) tbl_alternative_products:
#'This table contains a list of alternative products for the combination culture/pest organism
#'that can replace products with the active substance(s) you are looking for.
#'
#' @examples
#' name_active_ingredient <- c("Cypermethrin", "Lambda-Cyhalothrin","Etofenprox", "Deltamethrin")
#'
#'
#' alternative_products(name_active_ingredient)
#' print(list_alternative_product)




alternative_products <- function(name_active_ingredient) {

  list_alternative_product <- list()

   # The URL of the current version published by BLV
  psmv_xml_url <- paste0("https://www.blv.admin.ch/dam/blv/de/dokumente/",
                         "zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/",
                         "daten-pflanzenschutzmittelverzeichnis.zip.download.zip/",
                         "Daten%20Pflanzenschutzmittelverzeichnis.zip")

  psmv <- psmv_dm(psmv_xml_url)

  #Select entries from the PSM-V with the WS
  psmv_ai <- dm_filter(psmv,
                       substances = (substance_de %in% name_active_ingredient))


  ai_uses <- psmv_ai$uses |>
    left_join(psmv$cultures, by = join_by(wNbr, use_nr), relationship = "many-to-many") |>
    left_join(psmv$pests, by = join_by(wNbr, use_nr), relationship = "many-to-many") |>
    left_join(psmv$application_areas, by = join_by(wNbr, use_nr), relationship = "many-to-many")



  ai_pests_x_cultures_x_application_areas <- ai_uses |>
    select(culture_de, pest_de, application_area_de) |>
    unique() |>
    arrange(culture_de, pest_de, application_area_de)

  # psmv_alternative_products
  dm_comb_pesticide_cultur <-  dm_filter(psmv,
                                         cultures = (culture_de %in% ai_pests_x_cultures_x_application_areas$culture_de),
                                         pests= (pest_de %in% ai_pests_x_cultures_x_application_areas$pest_de),
                                         application_areas = (application_area_de %in% ai_pests_x_cultures_x_application_areas$application_area_de) )



  tbl.comb_pesticide_cultur <- dm_comb_pesticide_cultur$uses |>
    left_join(dm_comb_pesticide_cultur$cultures, by = join_by(wNbr, use_nr), relationship = "many-to-many") |>
    left_join(dm_comb_pesticide_cultur$pests, by = join_by(wNbr, use_nr), relationship = "many-to-many") |>
    left_join(dm_comb_pesticide_cultur$application_areas, by = join_by(wNbr, use_nr), relationship = "many-to-many")|>
    left_join(dm_comb_pesticide_cultur$products, by = join_by(wNbr), relationship = "many-to-many") |>
    left_join(dm_comb_pesticide_cultur$ingredients, by = join_by(wNbr), relationship = "many-to-many")|>
    left_join(dm_comb_pesticide_cultur$substances, by = join_by(pk), relationship = "many-to-many")|>
    dplyr::select(  wNbr, use_nr ,min_dosage ,max_dosage, waiting_period, min_rate, max_rate, units_de, culture_de, pest_de,
                    application_area_de,pNbr,  name, pk,percent, g_per_L,type.y ,substance_de)

  #remove all product names with active ingredients d_ai[1]
  tbl.psmv_alternative_products <- tbl.comb_pesticide_cultur |>
    dplyr::filter(!name %in% tbl.comb_pesticide_cultur[tbl.comb_pesticide_cultur$substance_de %in% name_active_ingredient,]$name)



  alt_comb <- unique(tbl.psmv_alternative_products[,c("wNbr","culture_de","pest_de","application_area_de")])



  alt_comb_count <- alt_comb %>%
    group_by(culture_de, pest_de, application_area_de) %>%
    summarize(number_alternative_products = n())

  #### Tables with all searched indications of this active substance (culture-pathogen combination) ####
  alt_comb_count_1 <- left_join(ai_pests_x_cultures_x_application_areas,alt_comb_count,by=c( "culture_de",   "pest_de",   "application_area_de"))

  alt_comb_count_1[is.na(alt_comb_count_1$number_alternative_products),]$number_alternative_products <- 0
  tbl_overview_culture_pest <- alt_comb_count_1


  ##### Append column for number of products with the active ingredient for which alternative products are sought #####
  for(i_ws_name in name_active_ingredient){

    tbl.comb_pesticide_cultur_comb <- tbl.comb_pesticide_cultur[tbl.comb_pesticide_cultur$substance_de %in% i_ws_name,]


    tbl.comb_pesticide_cultur_comb <- unique(tbl.comb_pesticide_cultur_comb[,c("wNbr","culture_de","pest_de","application_area_de")])


    count_product_per_indications <- tbl.comb_pesticide_cultur_comb %>%
      group_by( culture_de, pest_de,application_area_de ) %>%
      summarise(count = n(), .groups = "drop")


    tbl_overview_culture_pest <- left_join(tbl_overview_culture_pest,
                                           count_product_per_indications[,c("culture_de", "pest_de", "application_area_de","count")], by = c("culture_de", "pest_de", "application_area_de"))

    names(tbl_overview_culture_pest)[which(names(tbl_overview_culture_pest)  == "count") ] <- paste0("PSM_mit_",i_ws_name)


  }



  # Replace NA values with 0
  list_alternative_product[["tbl_overview_culture_pest"]] <- tbl_overview_culture_pest %>% replace(is.na(.), 0)

  #### Table with alternative products ####
  tbl_alternative_products <- left_join(ai_pests_x_cultures_x_application_areas,tbl.psmv_alternative_products,by=c( "culture_de",   "pest_de",  "application_area_de"))


  if(length(which(is.na(tbl_alternative_products$wNbr)== T))>1){
    print(paste0( "total of ", length(which(is.na(tbl_alternative_products$wNbr)== T)), " indication have no alternative products"))

    #delete such indications
    list_alternative_product[["tbl_alternative_products"]] <- tbl_alternative_products[-which(is.na(tbl_alternative_products$wNbr)),]
  }

  return(list_alternative_product)

}





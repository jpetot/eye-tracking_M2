# script qui prend en entree tout les consumers_name et qui genere toutes les heatmaps d'un coup

# get time_user_exp csv file

drive_path = "Eyetracking/1ter_resultats_exp/time_user_exp"
folder_path = "data/time_user_exp.csv"

# load the experience plan
load("experience/plan_exp.RData")

# drive_download(drive_path, path = folder_path, overwrite = TRUE)

time_user_exp  = read.csv(folder_path, sep = ",", header = TRUE)
col = colnames(time_user_exp)

# get the full lists of the different consumers
consumers_name_vec <- list.files("data/gazedata/")[1:3]

for(conso_iter in 1:length(consumers_name_vec)){
  
  consumers_name <- consumers_name_vec[conso_iter]
  
  consumers_number = as.numeric(gsub("([0-9]+).*$", "\\1", consumers_name))
  screen_size_input = c(9,16)
  
  start_time_vec = time_user_exp[time_user_exp$ordre == consumers_number ,grepl( "start_time", col, fixed = TRUE)]
  end_time_vec = time_user_exp[time_user_exp$ordre == consumers_number ,grepl( "end_time", col, fixed = TRUE)]
  
  # script to obtain the gaze data on the stimuli (16)
  source("script/1_data_processing/main_data_process.R")
  
  # sourcing helpers script for heatmap
  source("script/2_heatmap/helpers_heatmap_generator.R")
  
  # create heatmap folder
  dir.create(paste0("data/gazedata/",consumers_name,"/heatmap"))
  
  # extract the letters name from stimu_lvl to match each heatmap to their stimuli
  list_img <- list.files("experience/cockpit_utile/")
  
  # get the list order for a given consumer
  consumers_list <- plan_exp[consumers_number,] 
  
  # get the list_img in the order for a given consumer with their full path 
  list_img_order <- paste0("experience/cockpit_utile/",
                           list_img[order(match(substr(list_img,start=1,stop = 3),
                                                consumers_list))])
  
  # execute heatmap function 
  for(i in 2:length(stimu_lvl)){
    # if no correction, execute the following lines
    col <- colnames(df_corrected)
    df_corrected <- df[,1:4]
    colnames(df_corrected) <- col
    df_heatmaps = df_corrected[as.character(df_corrected$stimu) == stimu_lvl[i],]
    df_heatmaps = remove_first_time(df_heatmaps, t0 = (start_time_vec[1,k] + 10) ) 
    df_heatmaps = remove_last_time(df_heatmaps, t1 = end_time_vec[1,k])
    
    ## fin du if temporaire en attendant de corriger la classif,
    # bien changé df_heatmaps 
    heatmap_generator(df_heatmaps,
                      path_img = list_img_order[i-1], 
                      width_size = 640, height_size = 360, transparency_img = 0.6)
  }
}





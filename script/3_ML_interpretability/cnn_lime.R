
source("script/requirements.R")

# Script to load heatmaps data in a compatible and their 
# associated liking in a compatible shape for model inputs

# loading labeled data 
time_user_exp  = read.csv("data/time_user_exp.csv", sep = ",", header = TRUE)

##################################
##### CNN ########################
##################################

# sourcing pre-process script 
source("script/3_ML_interpretability/helpers_load_heatmap.R")

### load the heatmaps from the concerned folder ###

# temp variable declaration

method_name = "raw_image"

path_abs = "data/inputs_ML/"

channel = 3
height_size = 360
width_size = 640

# execute function

cnn_input <- loader_img(method_name = method_name, consumers_data = time_user_exp)


#### create train/test dataset ###

# n_train = round(length(cnn_input$y) * 0.8)
# ind_train = sample(1:length(cnn_input$y), n_train )

# #train
# x_train <- cnn_input$x[ind_train,,,]
# y_train <- as.array(cnn_input$y)[ind_train]
# 
# #test
# x_test <- cnn_input$x[-ind_train,,,]
# y_test <- as.array(cnn_input$y)[-ind_train]

###  keras algorithm

model <- keras_model_sequential() %>%
  layer_conv_2d(filters = 32, kernel_size = c(3,3), activation = "relu",
                input_shape = c(height_size,width_size,channel)) %>%
  layer_max_pooling_2d(pool_size = c(2,2)) %>%
  layer_conv_2d(filters = 64, kernel_size = c(3,3), activation = "relu") %>%
  layer_max_pooling_2d(pool_size = c(2,2)) %>%
  layer_conv_2d(filters = 64, kernel_size = c(3,3), activation = "relu")

model %>%
  layer_flatten() %>%
  layer_dense(units = 64, activation = "relu") %>%
  layer_dense(units = 1, activation = "softmax")

model %>% compile(
  optimizer = "adam",
  loss = "binary_crossentropy",
  metrics = c("accuracy")
)

class(cnn_input$y)

history <- model %>%
  fit(
    x = cnn_input$x, y = cnn_input$y,
    epochs = 4,
    validation_split = 0.2,
    verbose = 1
  )


plot(history)

################################################### 
################# LIME interpretability ################
################################################### 

img_path <- paste0(path_abs,method_name,"/",list_files)

image_prep2 <- function(x) {
  arrays <- lapply(x, function(path) {
    img <- image_load(path, target_size = c(180, 320))
    x <- image_to_array(img)
    x <- array_reshape(x, c(1, dim(x)))
    x <- imagenet_preprocess_input(x)
  })
  do.call(abind::abind, c(arrays, list(along = 1)))
}


# code chunk to manage superpixels combination 
pdf("data/test_pixels/test2020.pdf")
plots <- map(img_path[1:6],plot_superpixels,n_superpixels = 30, weight = 20) 
dev.off()
# possibility for superpixels combination
# pref : (30,30) ; (30,40) ;  best with 30, if too long (20,30) ; (20,40)


# write a function that is creating the necessary LIME outputs for all the 16*34 heatmaps



lime_explanator <- function(model = cnn_model){
  
  
  
}

explainer2 <- lime(c(img_path, img_path2), model = model, 
                   preprocess =  image_prep2)

explanation2 <- explain(c(img_path, img_path2), explainer2,
                        n_labels = 2, n_features = 10, weight = 10,n_superpixels = 10,
                        background = "white")

exp <- as.data.frame(explanation2)
desagreable <- exp[exp$case == "fake43.png",]
plot_image_explanation(desagreable)
agreable <- exp[exp$case == "fake100.png",]
plot_image_explanation(agreable)


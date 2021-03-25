library(data.table)
library(ggplot2); theme_set(theme_classic())

dat <- NULL
followers <- fread("followers.csv")
followers[, date := as.POSIXct(`Created At`, "%b %e, %Y, %r", tz="Europe/Amsterdam")]
followers <- followers[`Follow Status` == "Accepted"]
followers[, followers := 1:.N]

files <- Sys.glob("*.csv")
for(f in files){
  tdat <- fread(f)
  dat <- rbind(dat, tdat , fill = T)
}

dat[, date := start_date_local]

dat <- rbind(followers, dat, fill = T)
setkey(dat, date)
dat[, followers := nafill(followers, type = "nocb")]
dat[, followers := nafill(followers, type = "locf")]
dat[, k.f := kudos_count/followers]

ggplot(dat[type %in% c("Ride", "VirtualRide", "Run") & visibility != "only_me" & id > 405617303 & k.f < .3], aes(x = date, y = k.f, color = type)) +
  geom_smooth(se = F) +
  geom_point(alpha = .4, stroke = 0) +
  scale_color_brewer(palette = "Set1") 

ggplot(dat[type %in% c("Ride", "VirtualRide", "Run") & visibility != "only_me" & id > 405617303 & k.f < .3], aes(x = suffer_score, y = k.f, color = type)) +
  geom_smooth(method = "lm") +
  geom_point(alpha = .4, stroke = 0, size  = 2) +
  scale_color_brewer(palette = "Set1") +
  labs(y = "Kudos per Follower", x = "Suffer Score") +
  theme(legend.position = "bottom")

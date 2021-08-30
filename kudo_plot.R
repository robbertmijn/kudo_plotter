library(data.table)
library(ggplot2); theme_set(theme_classic())
library(lme4)

dat <- NULL
followers <- fread("followers.csv")
followers[, date := as.POSIXct(`Created At`, "%b %e, %Y, %r", tz="Europe/Amsterdam")]
followers <- followers[`Follow Status` == "Accepted"]
followers[, followers := 1:.N]

files <- Sys.glob("strava*.csv")
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
dat <- dat[is.na(`Follower Athlete ID`) ]

ggplot(dat[type %in% c("Ride", "VirtualRide", "Run") & visibility != "only_me" & id > 405617303 & k.f < .3], aes(x = date, y = k.f, color = type)) +
  geom_smooth(se = F) +
  geom_point(alpha = .4, stroke = 0) +
  scale_color_brewer(palette = "Set1") 

ggplot(dat[type %in% c("Ride", "VirtualRide") & visibility != "only_me" & id > 405617303], aes(x = suffer_score, y = kudos_count, color = type)) +
  geom_smooth(method = "lm") +
  geom_point(alpha = .4, stroke = 0, size  = 2) +
  scale_color_brewer(palette = "Set1") +
  labs(y = "Kudos per Ride", x = "Suffer Score") +
  theme(legend.position = "bottom")

ggplot(dat[type %in% c("Ride") & visibility != "only_me" & id > 405617303], aes(x = total_photo_count, y = kudos_count)) +
  geom_smooth(method = "lm") +
  geom_jitter(width = .2, height = 0, alpha = .4, stroke = 0, size  = 2) +
  labs(y = "Kudos per Ride", x = "Number of Photo's") +
  theme(legend.position = "bottom")

subset <- dat[type %in% c("Ride") & visibility != "only_me" & id > 405617303]
m0 <- lm(data = subset, kudos_count ~ 1)
m1 <- lm(data = subset, kudos_count ~ total_photo_count)

summary(m1)
exp((BIC(m0) - BIC(m1))/2)

subset <- dat[type %in% c("Ride", "VirtualRide") & visibility != "only_me" & id > 405617303]
m0 <- lm(data = subset, kudos_count ~ 1)
m1 <- lm(data = subset, kudos_count ~ suffer_score + type)
summary(m1)

ggplot(dat[type %in% c("Ride") & visibility != "only_me" & id > 405617303], aes(x = average_temp, y = kudos_count)) +
  geom_smooth(method = "lm") +
  geom_jitter(width = .2, height = 0, alpha = .4, stroke = 0, size  = 2) +
  labs(y = "Kudos per Ride", x = "Temperature") +
  theme(legend.position = "bottom")


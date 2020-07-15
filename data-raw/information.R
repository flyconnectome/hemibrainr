### Code to prepare neuron information ###
library(googledrive)

# Get matches
matches = hemibrain_matches()

## Olfactory projection neurons
### Depends on having the repo: hemibrain_olf_data
mpns.fib.info = read.csv("/Users/GD/LMBD/Papers/hemibrain_olf_data/FIB_mPNs.csv")
upns.fib.info = read.csv("/Users/GD/LMBD/Papers/hemibrain_olf_data/FIB_uPNs.csv")
vpns.fib.info = read.csv("/Users/GD/LMBD/Papers/hemibrain_olf_data/FIB_VP_PNs.csv")
odour.scenes = read.csv("/Users/GD/LMBD/Papers/hemibrain_olf_data/odour_scenes.csv")
colnames(odour.scenes) = c("glomerulus", "key_ligand", "odour_scene", "valence")
odour.scenes.agg = aggregate(list(odour.scenes=odour.scenes$odour_scene),
                             list(glomerulus=odour.scenes$glomerulus),
                             function(x) paste(unique(x), collapse="/"))
pn.info = plyr::rbind.fill(upns.fib.info,mpns.fib.info,vpns.fib.info)
pn.info$glomerulus = gsub("\\+.*","",pn.info$glomerulus)
pn.info = merge(pn.info, odour.scenes.agg, all.x = TRUE, all.y = FALSE)
pn.meta = neuprint_get_meta(pn.info$bodyid)
pn.info = merge(pn.info,
                pn.meta[,c("bodyid", "type", "status", "voxels", "pre", "post",
                           "cropped", "soma", "cellBodyFiber")],
                all.x = TRUE, all.y = FALSE)
pn.info$n.cell.type = sapply(pn.info$type, function(x) nrow(subset(pn.info,type==x)))
rownames(pn.info) = pn.info$bodyid
pn.info$class = ifelse(grepl("multi",pn.info$type),"mPN", "uPN")
pn.info$neurotransmitter = ifelse(pn.info$tract=="mlALT","GABA","acetylcholine")
pn.info$glomerulus = gsub(" ","",pn.info$glomerulus)
pn.info$glomerulus[pn.info$class=='mPN'] = "mPN"
pn.info$layer = hemibrain_olfactory_layers[match(pn.info$bodyid,hemibrain_olfactory_layers$node),"layer_mean"]
pn.info$ct.layer = NA
for(ct in unique(pn.info$cell.type)){
  layer = round(mean(subset(pn.info,cell.type==ct)$layer))
  pn.info$ct.layer[pn.info$cell.type==ct] = layer
}

# MBON information
mbon.info = neuprint_search(".*MBON.*")
mb_ann = hemibrainr:::gsheet_manipulation(FUN = googlesheets4::read_sheet,
                                          ss = "1NROq0fw-WXGgu_mcWWVW9-l3YOdWHk-nESkI23fz-bo",
                                          sheet = "MBON",
                                          return = TRUE)#read.csv("data-raw/annotations/mb_annotations.csv")
mbon.info = cbind(mbon.info,mb_ann[match(mbon.info$bodyid,mb_ann$bodyId),])
mbon.info[is.na(mbon.info)] = "unknown"
mbon.info = subset(mbon.info, compartments!=""&!is.na(compartments))
mbon.info$cell.type = paste0("MBON-",mbon.info$compartments)
mbon.info$class = "MBON"
rownames(mbon.info) = mbon.info$bodyid
mbon.info$layer = hemibrain_olfactory_layers[match(mbon.info$bodyid,hemibrain_olfactory_layers$node),"layer_mean"]
mbon.info$ct.layer = NA
for(ct in unique(mbon.info$cell.type)){
  layer = round(mean(subset(mbon.info,cell.type==ct)$layer))
  mbon.info$ct.layer[mbon.info$cell.type==ct] = layer
}
mbon.info$match = matches[as.character(mbon.info$bodyid),"match"]
mbon.info$quality = matches[as.character(mbon.info$bodyid),"quality"]

# Save information
usethis::use_data(pn.info, overwrite = TRUE)
usethis::use_data(mbon.info, overwrite = TRUE)
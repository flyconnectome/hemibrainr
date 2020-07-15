#######################################################################################
################################ hemibrain meat data ##################################
#######################################################################################

#' Read neurons from the hemibrain connectome project
#'
#' @description Read meta data for hemibrain neurons from NeuPrint and supplement this with other data available in this package.
#' Specifically, neuron lineage, class, olfactory system layer and FAFB match information,
#' as well as numbers related to neurons' putative axon-dendrite split, e.g. for synapses or cable length.
#'
#' @param x a vector of bodyids that can be read from \url{'https://neuprint.janelia.org/'}.
#' @param ... arguments passed to \code{neuprintr::neuprint_get_meta}.
#'
#' @return a \code{data.frame} with columns that can give a user neuron lineage and class information, as well as numbers
#' related to neurons' putative axon-dendrite split.
#'
#' @examples
#' \donttest{
#' \dontrun{
#'
#' # Get neurons
#' meta = hemibrain_get_meta("763730414")
#' View(meta)
#'
#' }}
#' @rdname hemibrain_get_meta
#' @export
#' @seealso \code{\link{hemibrain_splitpoints}}, \code{\link{hemibrain_flow_centrality}}, \code{\link{hemibrain_somas}},
#' \code{\link{hemibrain_precomputed_splitpoints}}, \code{\link{hemibrain_metrics}},\code{\link{hemibrain_olfactory_layers}}
#' \code{\link{hemibrain_hemilineages}}, \code{\link{classed.ids}}, \code{\link{hemibrain_read_neurons}}
hemibrain_get_meta <- function(x, ...){
  # Get information from neuprint
  nmeta = neuprintr::neuprint_get_meta(x, ...)

  # Add lineage information
  nmeta2 = merge(nmeta,hemibrain_hemilineages,all.x = TRUE, all.y = FALSE)
  nmeta2$FAFB = NULL

  # Neuron class
  nmeta$class = NA
  nmeta$class[nmeta$bodyid%in%dn.ids] = "DN"
  nmeta$class[nmeta$bodyid%in%ton.ids] = "TON"
  nmeta$class[nmeta$bodyid%in%lhn.ids] = "LHN"
  nmeta$class[nmeta$bodyid%in%rn.ids] = "RN"
  nmeta$class[nmeta$bodyid%in%orn.ids] = "ORN"
  nmeta$class[nmeta$bodyid%in%hrn.ids] = "HRN"
  nmeta$class[nmeta$bodyid%in%pn.ids] = "PN"
  nmeta$class[nmeta$bodyid%in%upn.ids] = "uPN"
  nmeta$class[nmeta$bodyid%in%mpn.ids] = "mPN"
  nmeta$class[nmeta$bodyid%in%vppn.ids] = "VPPN"
  nmeta$class[nmeta$bodyid%in%alln.ids] = "ALLN"
  nmeta$class[nmeta$bodyid%in%dan.ids] = "DAN"
  nmeta$class[nmeta$bodyid%in%mbon.ids] = "MBON"

  # Add match information
  nmeta2$FAFB.match = hemibrain_matched[as.character(nmeta2$bodyid),"match"]
  nmeta2$FAFB.match.quality = hemibrain_matched[as.character(nmeta2$bodyid),"quality"]

  # Add olfactory layer information
  nmeta2$layer = hemibrain_olfactory_layers[match(nmeta2$bodyid,hemibrain_olfactory_layers$node),"layer_mean"]
  nmeta2$ct.layer = NA
  for(ct in unique(nmeta2$type)){
    layer = round(mean(subset(nmeta2,type==ct)$layer))
    nmeta2$ct.layer[nmeta2$type==ct] = layer
  }

  # Add split information
  selcols=setdiff(colnames(hemibrainr::hemibrain_metrics), colnames(nmeta2))
  hemibrain_metrics_sel = hemibrainr::hemibrain_metrics[as.character(nmeta2$bodyid), selcols]
  nmeta2 = cbind(nmeta2, hemibrain_metrics_sel)
  rownames(nmeta2) = nmeta2$bodyid

  # Return
  nmeta2
}



fafb_set_hemilineage <- function(find,
                                 ItoLee_Hemilineage,
                                 delete.find = FALSE){

  neurons = catmaid::catmaid_skids(find)
  ann = grepl("annotation:",find)
  if(ann){

  }

}










#' Format TPM data
#' 
#' @param file_path TPMファイルのパス
#' @param gene_set 発現を比較したい遺伝子。ベクトル形式で入力する。
#' @param sample 系統名。ベクトル形式で入力する
#' @param replication 反復数
#'
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom dplyr %>%
#' @importFrom tidyr pivot_longer
#' @export
#'
data_arange <- function(file_path, gene_set, sample, replication){
  read.table(file_path) -> data
  dplyr::mutate(data, genes = rownames(data))  %>% 
  dplyr::filter(genes %in% gene_set) %>% 
  tidyr::pivot_longer(col = -genes, names_to = "SAMPLE", values_to = "TPM") %>% 
  dplyr::mutate(Group = rep(rep(sample, each = replication), length(gene_set)))
}

#' Create Boxplot to compare gene expression between different populations
#' 
#' @param file_path TPMファイルのパス
#' @param gene_set 発現を比較したい遺伝子。ベクトル形式で入力する。
#' @param sample 系統名。ベクトル形式で入力する
#' @param replication 反復数
#' @param pal ボックスの色。系統数の色をベクトル形式で入力する。
#'
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom dplyr %>%
#' @importFrom tidyr pivot_longer
#' @importFrom ggpubr ggboxplot
#' @export
#'

expression_box <- function(file_path, gene_set, sample, replication, pal){
  data_arange(file_path, gene_set, sample, replication) %>% 
  ggpubr::ggboxplot(x="Group", y="TPM", facet.by = "genes", 
            color = "Group", ylab = "TPM",
            size = 0.2, add="jitter", palette = pal, fill = "Group", alpha=0.4,
            add.params = list(size=1), 
            panel.labs.font = list(size = 12), 
            panel.labs.background = list(fill = "white", color = "black")) +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_text(size=10),
          axis.text = element_text(size=10),
          axis.text.x = element_text(size = 16),
          legend.position = "none")
}
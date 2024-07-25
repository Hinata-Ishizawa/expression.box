#' Create count table
#' 
#' @param directory_path RSEMで出力される.resultファイルがあるディレクトリのパス
#'
#' @importFrom dplyr select
#' @importFrom dplyr left_join
#' @importFrom dplyr %>%
#' @export
#'
generate_exp_table <- function(directory_path = "result"){
  file_list1 <- list.files(path = directory_path, full.names = TRUE)
  file_list2 <- list.files(path = directory_path, full.names = FALSE)
  data_n <- length(file_list1)
  filename <- file_list2[1]
  exp_count <- read.table(file_list1[1], head = T, sep = "\t") %>% 
    dplyr::select(gene_id, expected_count)
  colnames(exp_count)[colnames(exp_count) == "expected_count"] <- filename
  for (i in 2:data_n){
    filename <- file_list2[i]
    temporary <- read.table(file_list1[i], head = T, sep = "\t") %>% 
      dplyr::select(gene_id, expected_count)
    exp_count <- dplyr::left_join(exp_count, temporary, by = "gene_id")
    colnames(exp_count)[colnames(exp_count) == "expected_count"] <- filename
  }
  rownames(exp_count) <- exp_count$gene_id
  exp_count2 <- exp_count %>% 
    dplyr::select(-gene_id)
  write.table(exp_count2, file = "exp.counts.txt", sep = "\t", quote = FALSE, row.names = TRUE)
}

#' Create TPM table
#' 
#' @param directory_path RSEMで出力される.resultファイルがあるディレクトリのパス
#'
#' @importFrom dplyr select
#' @importFrom dplyr left_join
#' @importFrom dplyr %>%
#' @export
#'
generate_TPM_table <- function(directory_path = "result"){
  file_list1 <- list.files(path = directory_path, full.names = TRUE)
  file_list2 <- list.files(path = directory_path, full.names = FALSE)
  data_n <- length(file_list1)
  filename <- file_list2[1]
  TPM <- read.table(file_list1[1], head = T, sep = "\t") %>% 
    dplyr::select(gene_id, TPM)
  colnames(TPM)[colnames(TPM) == "TPM"] <- filename
  for (i in 2:data_n){
    filename <- file_list2[i]
    temporary <- read.table(file_list1[i], head = T, sep = "\t") %>% 
      dplyr::select(gene_id, TPM)
    TPM <- dplyr::left_join(TPM, temporary, by = "gene_id")
    colnames(TPM)[colnames(TPM) == "TPM"] <- filename
  }
  rownames(TPM) <- TPM$gene_id
  TPM2 <- TPM %>% 
    select(-gene_id)
  write.table(TPM2, file = "TPM.txt", sep = "\t", quote = FALSE, row.names = TRUE)
}

#' Create both of count table and TPM table
#' 
#' @param directory_path RSEMで出力される.resultファイルがあるディレクトリのパス
#'
#' @importFrom dplyr select
#' @importFrom dplyr left_join
#' @importFrom dplyr %>%
#' @export
#'
generate_both_table <- function(directory_path = "result"){
  generate_exp_table(directory_path)
  generate_TPM_table(directory_path)
}

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
data_arange <- function(file_path = "TPM.txt", gene_set, sample, replication = 3){
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
#' @importFrom ggplot2 theme
#' @importFrom ggplot2 element_blank
#' @importFrom ggplot2 element_text
#' @export
#'

expression_box <- function(file_path = "TPM.txt", gene_set, sample, replication = 3, pal = NULL){
  data_arange(file_path, gene_set, sample, replication) %>% 
  ggpubr::ggboxplot(x="Group", y="TPM", facet.by = "genes", ncol = length(gene_set), 
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

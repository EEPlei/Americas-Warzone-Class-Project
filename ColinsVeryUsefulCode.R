get_coda_parameter = function(coda, pattern)
{
  w = coda[[1]] %>% colnames() %>% str_detect(pattern)
  coda[[1]][,w,drop=FALSE]
}

post_summary = function(m, ci_width=0.95)
{
  d = data_frame(
    post_mean  = apply(m, 2, mean),
    post_med   = apply(m, 2, median),
    post_lower = apply(m, 2, quantile, probs=(1-ci_width)/2),
    post_upper = apply(m, 2, quantile, probs=1 - (1-ci_width)/2)
  )
  
  if (!is.null(colnames(m)))
    d = d %>% mutate(param = colnames(m)) %>% select(param,post_mean:post_upper)
  
  d
}

strip_attrs = function(obj)
{
  attributes(obj) = NULL
  obj
}

strip_class = function(obj)
{
  attr(obj,"class") = NULL
  obj
}
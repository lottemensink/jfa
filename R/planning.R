#' Frequentist and Bayesian Planning for Audit Samples
#'
#' @description This function calculates the required sample size for an audit, based on the poisson, binomial, or hypergeometric likelihood. A prior can be specified to perform Bayesian planning. The returned object is of class \code{jfaPlanning} and can be used with associated \code{print()} and \code{plot()} methods.
#'
#' @usage planning(materiality, confidence = 0.95, expectedError = 0, likelihood = "poisson", 
#'          N = NULL, maxSize = 5000, prior = FALSE, kPrior = 0, nPrior = 0)
#'
#' @param materiality   a value between 0 and 1 representing the materiality of the audit as a fraction of the total size or value.
#' @param confidence    the confidence level desired from the confidence bound (on a scale from 0 to 1). Defaults to 0.95, or 95\% confidence.
#' @param expectedError a fraction representing the percentage of expected mistakes in the sample relative to the total size, or a number (>= 1) that represents the number of expected mistakes.
#' @param likelihood    can be one of \code{binomial}, \code{poisson}, or \code{hypergeometric}.
#' @param N             the population size (required for hypergeometric calculations).
#' @param maxSize       the maximum sample size that is considered for calculations. Defaults to 5000 for efficiency. Increase this value if the samle size cannot be found due to it being too large (e.g., for low materialities).
#' @param prior         whether to use a prior distribution when planning. Defaults to \code{FALSE} for frequentist planning. If \code{TRUE}, the prior distribution is updated by the specified likelihood. Chooses a conjugate gamma distribution for the Poisson likelihood, a conjugate beta distribution for the binomial likelihood, and a conjugate beta-binomial distribution for the hypergeometric likelihood.
#' @param kPrior        the prior parameter \eqn{\alpha} (number of errors in the assumed prior sample).
#' @param nPrior        the prior parameter \eqn{\beta} (total number of observations in the assumed prior sample).
#' 
#' @details This section elaborates on the available likelihoods and corresponding prior distributions for the \code{likelihood} argument.
#' 
#' \itemize{
#'  \item{\code{poisson}:          The Poisson likelihood is used as a likelihood for monetary unit sampling (MUS). Its likelihood function is defined as: \deqn{p(x) = \frac{\lambda^x e^{-\lambda}}{x!}} The conjugate \emph{gamma(\eqn{\alpha, \beta})} prior has probability density function: \deqn{f(x; \alpha, \beta) = \frac{\beta^\alpha x^{\alpha - 1} e^{-\beta x}}{\Gamma(\alpha)}}}
#'  \item{\code{binomial}:         The binomial likelihood is used as a likelihood for record sampling \emph{with} replacement. Its likelihood function is defined as: \deqn{p(x) = {n \choose k} p^k (1 - p)^{n - k}} The conjugate \emph{beta(\eqn{\alpha, \beta})} prior has probability density function: \deqn{f(x; \alpha, \beta) = \frac{1}{Beta(\alpha, \beta)} x^{\alpha - 1} (1 - x)^{\beta - 1}}}
#'  \item{\code{hypergeometric}:   The hypergeometric likelihood is used as a likelihood for record sampling \emph{without} replacement. Its likelihood function is defined as: \deqn{p(x = k) = \frac{{K \choose k} {N - K \choose n - k}}{{N \choose n}}} The conjugate \emph{beta-binomial(\eqn{\alpha, \beta})} prior (Dyer and Pierce, 1993) has probability density function: \deqn{f(k | n, \alpha, \beta) = {n \choose k} \frac{Beta(k + \alpha, n - k + \beta)}{Beta(\alpha, \beta)}} }
#' }
#'
#' @return An object of class \code{jfaPlanning} containing:
#' 
#' \item{materiality}{the value of the specified materiality.}
#' \item{confidence}{the confidence level for the desired population statement.}
#' \item{sampleSize}{the resulting sample size.}
#' \item{expectedSampleError}{the number of full errors that are allowed to occur in the sample.}
#' \item{expectedError}{the specified number of errors as a fraction or as a number.}
#' \item{likelihood}{the specified likelihood.}
#' \item{errorType}{whether the expected errors where specified as a percentage or as an integer.}
#' \item{N}{the population size (only returned in case of a hypergeometric likelihood).}
#' \item{populationK}{the assumed population errors (only returned in case of a hypergeometric likelihood).}
#' \item{prior}{a list containing information on the prior parameters.}
#'
#' @author Koen Derks, \email{k.derks@nyenrode.nl}
#'
#' @seealso \code{\link{sampling}} \code{\link{evaluation}}
#'
#' @references Dyer, D. and Pierce, R.L. (1993). On the Choice of the Prior Distribution in Hypergeometric Sampling. \emph{Communications in Statistics - Theory and Methods}, 22(8), 2125 - 2146.
#'
#' @examples
#' 
#' library(jfa)
#' 
#' # Using the binomial distribution, calculates the required sample size for a 
#' # materiality of 5% when 2.5% mistakes are expected to be found in the sample.
#' 
#' # Frequentist planning with binomial likelihood.
#' planning(materiality = 0.05, confidence = 0.95, expectedError = 0.025, 
#'          likelihood = "binomial")
#' 
#' # Bayesian planning with uninformed prior.
#' planning(materiality = 0.05, confidence = 0.95, expectedError = 0.025, 
#'          likelihood = "binomial", prior = TRUE)
#' 
#' # Bayesian planning with informed prior (based on 10 correct observations).
#' planning(materiality = 0.05, confidence = 0.95, expectedError = 0.025, 
#'          likelihood = "binomial", prior = TRUE, kPrior = 0, nPrior = 10)
#'
#' @keywords planning sample size
#'
#' @export

planning <- function(materiality, confidence = 0.95, expectedError = 0, likelihood = "poisson", 
                     N = NULL, maxSize = 5000, prior = FALSE, kPrior = 0, nPrior = 0){
  
  if(is.null(materiality))
    stop("Specify the materiality")
  if(!(likelihood %in% c("binomial", "hypergeometric", "poisson")))
    stop("Specify a valid distribution")
  # if(prior && is.null(kPrior) && is.null(nPrior))
  #   stop("When you specify a prior, both kPrior and nPrior should be specified")
  if(prior && (kPrior < 0 || nPrior < 0))
    stop("When you specify a prior, both kPrior and nPrior should be higher than zero")
  
  ss <- NULL
  
  if(expectedError >= 0 && expectedError < 1){
    errorType <- "percentage"
    if(expectedError >= materiality)
      stop("The expected errors are higher than materiality")
    startN <- 1
  } else if(expectedError >= 1){
    errorType <- "integer"
    startN <- expectedError
    if(expectedError%%1 != 0 && likelihood %in% c("binomial", "hypergeometric"))
      stop("When expectedError > 1 and the likelihood is binomial or hypergeometric, the value must be an integer.")
  }
  
  if(likelihood == "poisson"){
    for(i in startN:maxSize){
      if(errorType == "percentage"){
        implicitK <- ceiling(expectedError * i)
      } else if(errorType == "integer"){
        implicitK <- expectedError
      }
      if(prior){
        bound <- stats::qgamma(confidence, shape = 1 + kPrior + implicitK, rate = nPrior + i)
        if(bound < materiality){
          ss <- i
          break
        }
      } else {
        prob <- stats::pgamma(materiality, shape = 1 + implicitK, rate = i)
        if(prob > confidence){
          ss <- i
          break
        }
      }
    }
  } else if(likelihood == "binomial"){
    for(i in startN:maxSize){
      if(errorType == "percentage"){
        implicitK <- ceiling(expectedError * i)
      } else if(errorType == "integer"){
        implicitK <- expectedError
      }
      if(prior){
        bound <- stats::qbeta(confidence, shape1 = 1 + kPrior + implicitK, shape2 = 1 + nPrior - kPrior + i - implicitK)
        if(bound < materiality){
          ss <- i
          break
        }
      } else {
        prob <- stats::dbinom(0:implicitK, size = i, prob = materiality)
        if(sum(prob) < (1 - confidence)){
          ss <- i
          break
        }
      }
    }
  } else if(likelihood == "hypergeometric"){
    if(is.null(N))
      stop("Specify a population size N")
    populationK <- ceiling(materiality * N)
    for(i in startN:maxSize){
      if(errorType == "percentage"){
        implicitK <- ceiling(expectedError * i)
      } else if(errorType == "integer"){
        implicitK <- expectedError
      }
      if(prior){
        bound <- .qBetaBinom(p = confidence, N = N - i, shape1 = 1 + kPrior + implicitK, shape2 = 1 + nPrior - kPrior + i - implicitK) / N
        if(bound < materiality){
          ss <- i
          break
        }
      } else {
        prob <- stats::dhyper(x = 0:implicitK, m = populationK, n = N - populationK, k = i)
        if(sum(prob) < (1 - confidence)){
          ss <- i
          break
        }
      }
    }
  }
  
  if(is.null(ss))
    stop("Sample size could not be calculated, please increase the maxSize argument")
  
  results <- list()
  results[["materiality"]]          <- as.numeric(materiality)
  results[["confidence"]]           <- as.numeric(confidence)
  results[["sampleSize"]]           <- as.numeric(ceiling(ss))
  results[["expectedSampleError"]]  <- as.numeric(implicitK)
  results[["expectedError"]]        <- as.numeric(expectedError)
  results[["likelihood"]]           <- as.character(likelihood)
  results[["errorType"]]            <- as.character(errorType)
  if(likelihood == "hypergeometric"){
    results[["N"]]                  <- as.numeric(N)
    results[["populationK"]]        <- as.numeric(populationK)
  }
  results[["prior"]]                <- list()
  results[["prior"]]$prior          <- as.logical(prior)
  if(prior){
    results[["prior"]]$priorD       <- switch(likelihood, "poisson" = "gamma", "binomial" = "beta", "hypergeometric" = "beta-binomial")
    results[["prior"]]$kPrior       <- as.numeric(kPrior)
    results[["prior"]]$nPrior       <- as.numeric(nPrior)
    results[["prior"]]$aPrior       <- 1 + results[["prior"]]$kPrior
    results[["prior"]]$bPrior       <- ifelse(likelihood == "poisson", yes = nPrior, no = 1 + nPrior - kPrior)
  }
  class(results)                    <- "jfaPlanning"
  return(results)
}
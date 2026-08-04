# A default for a common option that individual drivers may override:
# between the mirror seeds (1400) and the declaration defaults (1500), so a
# top-level definition reaches the mirrors, but the bare default does not
# override a driver's choice. mkDefault (1000) cannot express this: it would
# beat the seeds, cutting the mirrors off from the top-level values.
{ lib }:

lib.mkOverride 1450

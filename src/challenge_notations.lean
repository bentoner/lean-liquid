import banach
import real_measures.condensed
import condensed.projective_resolution
import for_mathlib.Profinite.extend
import for_mathlib.abelian_category
import for_mathlib.derived.K_projective

open_locale nnreal
open opposite category_theory

universe u

noncomputable theory

variables (p' p : ℝ≥0) [fact (0 < p')] [fact (p' ≤ 1)] [fact (p' < p)]

localized "notation `ℳ_{` p' `}` S := (real_measures.condensed p').obj S"
  in liquid_tensor_experiment

abbreviation liquid_tensor_experiment.Ext (i : ℤ) (A B : Condensed.{u} Ab.{u+1}) :=
((Ext' i).obj (op A)).obj B

instance : has_coe (pBanach.{u} p) (Condensed.{u} Ab.{u+1}) :=
{ coe := λ V, Condensed.of_top_ab V }

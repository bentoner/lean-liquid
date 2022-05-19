
import for_mathlib.derived.les_facts
import laurent_measures.ses2
import invpoly.ses
import Lbar.ses
import Lbar.ext
import free_pfpng.acyclic
import challenge_notations

.

universe u

open category_theory
open_locale nnreal

namespace laurent_measures

variables (p' p : ℝ≥0) [fact (0 < p')] [fact (p' < p)] [fact (p ≤ 1)]
variables (S : Profinite.{0})

local notation `r'` := @r p'
local notation `r` := @r p

-- move me
instance fact_half_pos : fact ((0:ℝ≥0) < 2⁻¹) := ⟨by simp⟩

lemma epi_and_is_iso
  (V : SemiNormedGroup.{0}) [normed_with_aut r V] [complete_space V] [separated_space V]
  (hV : ∀ (v : V), (normed_with_aut.T.inv v) = 2 • v) :
  epi (((Ext' 0).map ((condensify_Tinv2 (Fintype_LaurentMeasures r')).app S).op).app
    (Condensed.of_top_ab V)) ∧
  ∀ i > 0, is_iso (((Ext' i).map ((condensify_Tinv2 (Fintype_LaurentMeasures r')).app S).op).app
    (Condensed.of_top_ab V)) :=
begin
  have SES := Lbar.short_exact.{0 0} r' S,
  haveI : fact (r < r'),
  { refine ⟨nnreal.rpow_lt_rpow_of_exponent_gt _ _ _⟩,
    { exact fact.out _ },
    { apply nnreal.two_inv_lt_one },
    { norm_cast, exact fact.out _ },
  },
  haveI : fact (r < 1) := ⟨(fact.out _ : r < r').trans (fact.out _)⟩,
  haveI : fact (p' ≤ 1) := ⟨(fact.out _ : p' < p).le.trans (fact.out _)⟩,
  haveI : fact (p' < 1) := ⟨lt_of_lt_of_le (fact.out _ : p' < p) (fact.out _ : p ≤ 1)⟩,
  rw ← epi_and_is_iso_iff_of_is_iso _ _ _ _
    ((condensify_Tinv2 _).app S) ((condensify_Tinv2 _).app S) ((condensify_Tinv2 _).app S)
    _ _ (Condensed.of_top_ab V) SES SES (Lbar.is_iso_Tinv2 r r' S V hV),
  { rw ← is_zero_iff_epi_and_is_iso _ _ (Condensed.of_top_ab V) (invpoly.short_exact p' S),
    intros i hi,
    apply (free_pfpng_acyclic S V i hi).of_iso _,
    apply iso.app _ _,
    refine (Ext' i).map_iso _,
    exact (as_iso ((cond_free_pfpng_to_normed_free_pfpng.{0 0} p').app S)).op, },
  { rw [← nat_trans.comp_app, condensify_map_comp_Tinv2, nat_trans.comp_app], },
  { rw [← nat_trans.comp_app, condensify_map_comp_Tinv2, nat_trans.comp_app], }
end


end laurent_measures

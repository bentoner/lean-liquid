import for_mathlib.equalizers
import pseudo_normed_group.CLC

open_locale classical nnreal
noncomputable theory
local attribute [instance] type_pow

open NormedGroup opposite Profinite pseudo_normed_group category_theory breen_deligne
open profinitely_filtered_pseudo_normed_group category_theory.limits

universe variable u
variables (r : ℝ≥0) (V : NormedGroup) [normed_with_aut r V] [fact (0 < r)]
variables (r' : ℝ≥0) [fact (0 < r')] [fact (r' ≤ 1)] {M M₁ M₂ M₃ : Type u}
variables [profinitely_filtered_pseudo_normed_group_with_Tinv r' M]
variables [profinitely_filtered_pseudo_normed_group_with_Tinv r' M₁]
variables [profinitely_filtered_pseudo_normed_group_with_Tinv r' M₂]
variables [profinitely_filtered_pseudo_normed_group_with_Tinv r' M₃]
variables (c c₁ c₂ c₃ c₄ : ℝ≥0) (l m n : ℕ)
variables (f : profinitely_filtered_pseudo_normed_group_with_Tinv_hom r' M₁ M₂)
variables (g : profinitely_filtered_pseudo_normed_group_with_Tinv_hom r' M₂ M₃)

/-- The "functor" that sends `M` and `c` to `V-hat((filtration M c)^n)^{T⁻¹}`,
defined by taking `T⁻¹`-invariants
for two different actions by `T⁻¹`:

* The first comes from the action of `T⁻¹` on `M`.
* The second comes from the action of `T⁻¹` on `V`.

We take the equalizer of those two actions.

See the lines just above Definition 9.3 of [Analytic]. -/
def CLCFPTinv (r : ℝ≥0) (V : NormedGroup) (r' : ℝ≥0) (M : Type*) (c : ℝ≥0) (n : ℕ)
  [normed_with_aut r V] [fact (0 < r)] [fact (0 < r')] [fact (r' ≤ 1)]
  [profinitely_filtered_pseudo_normed_group_with_Tinv r' M] :
  NormedGroup :=
equalizer (CLCFP.Tinv V r' c n) (CLCFP.T_inv r V r' c n ≫ (@CLCFP.res V r' M _ _ _ n _))

namespace CLCFPTinv

def map : CLCFPTinv r V r' M₂ c n ⟶ CLCFPTinv r V r' M₁ c n :=
equalizer.map (CLCFP.map _ _ _ _ f) (CLCFP.map _ _ _ _ f)
(CLCFP.map_comp_Tinv _ _ _ _ _).symm $
by rw [← category.assoc, CLCFP.map_comp_T_inv, category.assoc, category.assoc, CLCFP.map_comp_res]

variables (M)

@[simp] lemma map_id :
  map r V r' c n (profinitely_filtered_pseudo_normed_group_with_Tinv_hom.id) =
    𝟙 (CLCFPTinv r V r' M c n) :=
by { simp only [map, equalizer.map_id, CLCFP.map_id], refl }

variables {M}

lemma map_comp : map r V r' c n (g.comp f) = map r V r' c n g ≫ map r V r' c n f :=
by simp only [map, equalizer.map_comp_map, CLCFP.map_comp]

def res [fact (c₁ ≤ c₂)] : CLCFPTinv r V r' M c₂ n ⟶ CLCFPTinv r V r' M c₁ n :=
equalizer.map (CLCFP.res _ _ _ _ _) (CLCFP.res _ _ _ _ _)
(CLCFP.res_comp_Tinv _ _ _ _ _).symm $
begin
  haveI : fact (r' * c₁ ≤ c₂) :=
    le_trans (show fact (r' * c₁ ≤ c₁), by apply_instance) ‹c₁ ≤ c₂›,
  rw [← category.assoc],
  simp only [CLCFP.res_comp_T_inv, category.assoc],
  rw [CLCFP.res_comp_res, CLCFP.res_comp_res],
end

@[simp] lemma res_refl : @res r V _ _ r' _ _ M _ c c n _ = 𝟙 _ :=
by { simp only [res, equalizer.map_id, CLCFP.res_refl], refl }

lemma res_comp_res [fact (c₁ ≤ c₂)] [fact (c₂ ≤ c₃)] [fact (c₁ ≤ c₃)] :
  res r V r' c₂ c₃ n ≫ res r V r' c₁ c₂ n = @res r V _ _ r' _ _ M _ c₁ c₃ n _ :=
by simp only [res, equalizer.map_comp_map, CLCFP.res_comp_res]

lemma map_comp_res [fact (c₁ ≤ c₂)] :
  map r V r' c₂ n f ≫ res r V r' c₁ c₂ n = res r V r' c₁ c₂ n ≫ map r V r' c₁ n f :=
by simp only [map, res, equalizer.map_comp_map, CLCFP.map_comp_res]

end CLCFPTinv

namespace breen_deligne

open CLCFPTinv

variables (M) {l m n}

namespace basic_universal_map

variables (ϕ : basic_universal_map m n)

def eval_CLCFPTinv [ϕ.suitable c₁ c₂] :
  CLCFPTinv r V r' M c₂ n ⟶ CLCFPTinv r V r' M c₁ m :=
equalizer.map (ϕ.eval_CLCFP _ _ _ _ _) (ϕ.eval_CLCFP _ _ _ _ _)
(Tinv_comp_eval_CLCFP _ _ _ _ _ _) $
by rw [category.assoc, res_comp_eval_CLCFP V r' M (r' * c₁) c₁ (r' * c₂) c₂,
    ← category.assoc, T_inv_comp_eval_CLCFP, category.assoc]

lemma map_comp_eval_CLCFPTinv [ϕ.suitable c₁ c₂] :
  map r V r' c₂ n f ≫ ϕ.eval_CLCFPTinv r V r' M₁ c₁ c₂ =
    ϕ.eval_CLCFPTinv r V r' M₂ c₁ c₂ ≫ map r V r' c₁ m f :=
by simp only [map, eval_CLCFPTinv, equalizer.map_comp_map, map_comp_eval_CLCFP]

lemma res_comp_eval_CLCFPTinv
  [fact (c₁ ≤ c₂)] [ϕ.suitable c₂ c₄] [ϕ.suitable c₁ c₃] [fact (c₃ ≤ c₄)] :
  res r V r' c₃ c₄ n ≫ ϕ.eval_CLCFPTinv r V r' M c₁ c₃ =
    ϕ.eval_CLCFPTinv r V r' M c₂ c₄ ≫ res r V r' c₁ c₂ m :=
by simp only [res, eval_CLCFPTinv, equalizer.map_comp_map,
  res_comp_eval_CLCFP V r' _ c₁ c₂ c₃ c₄,
  res_comp_eval_CLCFP V r' _ (r' * c₁) (r' * c₂) (r' * c₃) (r' * c₄)]

end basic_universal_map

namespace universal_map

variables (ϕ : universal_map m n)

def eval_CLCFPTinv [ϕ.suitable c₁ c₂] :
  CLCFPTinv r V r' M c₂ n ⟶ CLCFPTinv r V r' M c₁ m :=
equalizer.map (ϕ.eval_CLCFP _ _ _ _ _) (ϕ.eval_CLCFP _ _ _ _ _)
(Tinv_comp_eval_CLCFP _ _ _ _ _ _) $
by rw [category.assoc, res_comp_eval_CLCFP V r' M (r' * c₁) c₁ (r' * c₂) c₂,
    ← category.assoc, T_inv_comp_eval_CLCFP, category.assoc]

@[simp] lemma eval_CLCFPTinv_zero :
  (0 : universal_map m n).eval_CLCFPTinv r V r' M c₁ c₂ = 0 :=
begin
  apply equalizer.hom_ext,
  simp only [eval_CLCFPTinv, eval_CLCFP_zero, zero_comp, equalizer.map_ι, comp_zero]
end

open category_theory.limits

lemma eval_CLCFPTinv_comp (g : universal_map m n) (f : universal_map l m)
  [hg : g.suitable c₂ c₃] [hf : f.suitable c₁ c₂] [(comp g f).suitable c₁ c₃] :
  (comp g f).eval_CLCFPTinv r V r' M c₁ c₃ =
    g.eval_CLCFPTinv r V r' M c₂ c₃ ≫ f.eval_CLCFPTinv r V r' M c₁ c₂ :=
by simp only [eval_CLCFPTinv, equalizer.map_comp_map, ← eval_CLCFP_comp]

lemma map_comp_eval_CLCFPTinv [ϕ.suitable c₁ c₂] :
  map r V r' c₂ n f ≫ ϕ.eval_CLCFPTinv r V r' M₁ c₁ c₂ =
    ϕ.eval_CLCFPTinv r V r' M₂ c₁ c₂ ≫ map r V r' c₁ m f :=
by simp only [map, eval_CLCFPTinv, equalizer.map_comp_map, map_comp_eval_CLCFP]

lemma res_comp_eval_CLCFPTinv
  [fact (c₁ ≤ c₂)] [ϕ.suitable c₂ c₄] [ϕ.suitable c₁ c₃] [fact (c₃ ≤ c₄)] :
  res r V r' c₃ c₄ n ≫ ϕ.eval_CLCFPTinv r V r' M c₁ c₃ =
    ϕ.eval_CLCFPTinv r V r' M c₂ c₄ ≫ res r V r' c₁ c₂ m :=
by simp only [res, eval_CLCFPTinv, equalizer.map_comp_map,
  res_comp_eval_CLCFP V r' _ c₁ c₂ c₃ c₄,
  res_comp_eval_CLCFP V r' _ (r' * c₁) (r' * c₂) (r' * c₃) (r' * c₄)]

end universal_map

end breen_deligne

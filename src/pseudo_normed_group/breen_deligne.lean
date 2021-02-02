import pseudo_normed_group.basic
import pseudo_normed_group.category
import breen_deligne.suitable

import for_mathlib.add_monoid_hom

noncomputable theory

local attribute [instance] type_pow

open_locale nnreal big_operators matrix

namespace breen_deligne

namespace basic_universal_map

variables {m n : ℕ} (f : basic_universal_map m n)
variables (M : Type*)

section pseudo_normed_group

variables [pseudo_normed_group M]

open add_monoid_hom pseudo_normed_group

-- TODO: make this definition readable.
/-- `f.eval_png` is the group homomorphism `(M^m) →+ (M^n)`
obtained by matrix multiplication with the matrix `f`.

Implementation detail: We currently cannot multiply a matrix with `ℤ`-coefficients
with a vector with coefficients in a `ℤ`-module.
Hence we write out the definition of the homomorphism in a slightly convoluted way.
See the lemma `eval_png_apply` for a readable formula. -/
def eval_png : (M^m) →+ (M^n) :=
mk_to_pi $ λ j, mk_from_pi $ λ i, const_smul_hom _ $ f j i

lemma eval_png_apply (x : M^m) : f.eval_png M x = λ j, ∑ i, f j i • (x i) :=
begin
  ext j,
  simp only [eval_png, coe_mk_from_pi, add_monoid_hom.apply_apply, mk_to_pi_apply,
    add_monoid_hom.to_fun_eq_coe, fintype.sum_apply, function.comp_app, coe_gsmul,
    @mk_from_pi_apply M _ (fin m) _ (λ _, M) _ _ x, const_smul_hom_apply]
end

@[simp] lemma eval_png_zero : (0 : basic_universal_map m n).eval_png M = 0 :=
by { ext, simp only [eval_png_apply, zero_smul, finset.sum_const_zero, matrix.zero_apply], refl }

lemma eval_png_mem_filtration :
  (f.eval_png M) ∈ filtration ((M^m) →+ (M^n)) (finset.univ.sup $ λ i, ∑ j, (f i j).nat_abs) :=
begin
  apply mk_to_pi_mem_filtration,
  intro j,
  refine filtration_mono (finset.le_sup (finset.mem_univ j)) (mk_from_pi_mem_filtration _ _),
  intros i,
  exact const_smul_hom_int_mem_filtration _ _ le_rfl
end

lemma eval_png_comp {l m n} (g : basic_universal_map m n) (f : basic_universal_map l m) :
  (g.comp f).eval_png M = (g.eval_png M).comp (f.eval_png M) :=
begin
  ext x j,
  simp only [eval_png_apply, function.comp_app, coe_comp, basic_universal_map.comp,
    matrix.mul_apply, finset.smul_sum, finset.sum_smul, mul_smul],
  rw finset.sum_comm
end

end pseudo_normed_group

section profinitely_filtered_pseudo_normed_group

variables [profinitely_filtered_pseudo_normed_group M]

lemma pfpng_ctu'_eval_png : pfpng_ctu' (f.eval_png M) :=
begin
  have : (f.eval_png M : M^m → M^n) = ∑ i, λ x j, f j i • (x i),
  { ext x j,
    rw [f.eval_png_apply M x, finset.sum_apply, finset.sum_apply] },
  rw this,
  refine pfpng_ctu'_sum _ _ _,
  rintro i -,
  refine pfpng_ctu'_of_pfpng_ctu i (λ (x : M) j, f j i • x) _,
  intro j,
  exact pfpng_ctu_smul_int _ _
end

end profinitely_filtered_pseudo_normed_group

end basic_universal_map

end breen_deligne
#lint- only unused_arguments def_lemma doc_blame

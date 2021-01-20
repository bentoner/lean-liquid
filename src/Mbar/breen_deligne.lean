import Mbar.Mbar_le
import pseudo_normed_group.breen_deligne
import for_mathlib.normed_group_hom

/-!
# The interplay between Breen--Deligne data and `Mbar_le`

In this file we define how `universal_map`s
(typically part of some BD package)
act on powers of the spaces `Mbar_le r' S c`.
This is not completely straight-forward, since `Mbar_le r' S c`
is not stable under addition: the `c` changes.
We therefore have some sort of "moving target".

We also show that the resulting maps are continuous
for the profinite topology on `Mbar_le`.
-/

local attribute [instance] type_pow

noncomputable theory

open_locale big_operators nnreal

open normed_group_hom normed_group

namespace breen_deligne

namespace basic_universal_map

variables {k l m n : ℕ}
variables (r' : ℝ≥0) (S : Type*) (c c₁ c₂ c₃ : ℝ≥0) [fintype S]
variables (f : basic_universal_map m n)

/-- Addition goes from `Mbar r' S c` to `Mbar r' S c'` for suitable `c'`.
This predicate says what *suitable* means for basic universal maps.
See Lemma 9.11 of [Analytic]. -/
def suitable (f : basic_universal_map m n) (c₁ c₂ : ℝ≥0) : Prop :=
∀ i, (∑ j, ↑(f i j).nat_abs) * c₁ ≤ c₂

attribute [class] suitable

lemma sup_mul_le (f : basic_universal_map m n) {c₁ c₂ : ℝ≥0} [h : f.suitable c₁ c₂] :
  (finset.univ.sup $ λ i, ∑ j, ↑(f i j).nat_abs) * c₁ ≤ c₂ :=
begin
  by_cases H : c₁ = 0,
  { unfreezingI {subst H}, rw mul_zero, exact zero_le' },
  rw [mul_comm, nnreal.mul_le_iff_le_inv H, finset.sup_le_iff],
  rintro i -,
  rw [← nnreal.mul_le_iff_le_inv H, mul_comm],
  apply h
end

instance suitable_of_mul_left (f : basic_universal_map m n) [h : f.suitable c₁ c₂] :
  f.suitable (c * c₁) (c * c₂) :=
λ i, by { rw mul_left_comm, exact mul_le_mul' le_rfl (h i) }

-- move this
lemma nat_abs_sum_le_sum_nat_abs {ι : Type*} (s : finset ι) (f : ι → ℤ) :
  (∑ i in s, f i).nat_abs ≤ ∑ i in s, (f i).nat_abs :=
begin
  classical,
  apply finset.induction_on s,
  { simp only [finset.sum_empty, int.nat_abs_zero] },
  { intros i s his IH,
    simp only [his, finset.sum_insert, not_false_iff],
    exact (int.nat_abs_add_le _ _).trans (add_le_add le_rfl IH) }
end

-- this cannot be an instance, because c₂ cannot be inferred
lemma suitable_comp {g : basic_universal_map m n} {f : basic_universal_map l m}
  {c₁ : ℝ≥0} (c₂ : ℝ≥0) {c₃ : ℝ≥0}
  [hg : g.suitable c₂ c₃] [hf : f.suitable c₁ c₂] :
  (g.comp f).suitable c₁ c₃ :=
begin
  intro i,
  simp only [← nat.coe_cast_ring_hom, ← ring_hom.map_sum, comp, matrix.mul_apply],
  calc  ↑(∑ k, (∑ j, g i j * f j k).nat_abs) * c₁
      ≤ ↑(∑ j, (g i j).nat_abs * ∑ k, (f j k).nat_abs) * c₁    : _ -- proof below
  ... = ∑ j, ↑(g i j).nat_abs * ((∑ k, ↑(f j k).nat_abs) * c₁) : _ -- proof below
  ... ≤ ∑ j, ↑(g i j).nat_abs * c₂                             : _ -- proof below
  ... ≤ c₃                                                 : by { rw ← finset.sum_mul, exact hg i },
  { refine mul_le_mul' _ le_rfl,
    rw nat.cast_le,
    simp only [finset.mul_sum],
    rw finset.sum_comm,
    apply finset.sum_le_sum,
    rintro k -,
    simp only [← int.nat_abs_mul],
    apply nat_abs_sum_le_sum_nat_abs },
  { simp only [← nat.coe_cast_ring_hom, ring_hom.map_sum, ring_hom.map_mul,
      finset.sum_mul, mul_assoc] },
  { apply finset.sum_le_sum, rintro j -, exact mul_le_mul' le_rfl (hf j) }
end

instance zero_suitable : (0 : basic_universal_map m n).suitable c₁ c₂ :=
λ i, by simp only [nat.cast_zero, zero_mul, zero_le', finset.sum_const_zero,
          matrix.zero_apply, int.nat_abs_zero]

/-- `f.eval_Mbar_le` for `f : basic_universal_map m n` is
the map `(Mbar_le r' S c₁)^m → (Mbar_le r' S c₂)^n` induced
by the natural map `(Mbar r' S)^m → (Mbar r' S)^n` associated with `f`. -/
def eval_Mbar_le [H : f.suitable c₁ c₂] :
  ((Mbar_le r' S c₁)^m) → ((Mbar_le r' S c₂)^n) :=
Mbar_le.hom_of_normed_group_hom' r' S c₁ c₂ f.sup_mul_le (f.eval_png (Mbar r' S)) $
λ c F hF, eval_png_mem_filtration _ _ hF

@[simp] lemma eval_Mbar_le_apply [f.suitable c₁ c₂]
  (x : (Mbar_le r' S c₁)^m) (j : fin n) (s : S) (i : ℕ) :
  (f.eval_Mbar_le r' S c₁ c₂ x j) s i = f.eval_png (Mbar r' S) (λ i, x i) j s i :=
rfl

@[simp] lemma eval_Mbar_le_zero : eval_Mbar_le r' S c₁ c₂ (0 : basic_universal_map m n) = 0 :=
begin
  ext j s i,
  simp only [eval_Mbar_le, pi.zero_apply, Mbar_le.coe_hom_of_normed_group_hom'_apply,
    Mbar.coe_zero, eval_png_zero, add_monoid_hom.coe_zero],
  refl
end

lemma eval_Mbar_le_comp (f : basic_universal_map m n) (g : basic_universal_map l m)
  [f.suitable c₂ c₁] [g.suitable c₃ c₂] [(f.comp g).suitable c₃ c₁] :
  (f.comp g).eval_Mbar_le r' S c₃ c₁ = f.eval_Mbar_le r' S c₂ c₁ ∘ g.eval_Mbar_le r' S c₃ c₂ :=
begin
  ext j s i,
  simp only [eval_Mbar_le, Mbar_le.coe_hom_of_normed_group_hom'_apply],
  rw eval_png_comp,
  simp only [add_monoid_hom.coe_comp, function.comp_app],
  congr' 2,
  ext,
  simp only [Mbar_le.coe_hom_of_normed_group_hom'_apply, Mbar_le.coe_coe_to_fun],
end

open add_monoid_hom (apply)

lemma eval_Mbar_le_continuous [f.suitable c₁ c₂] :
  continuous (f.eval_Mbar_le r' S c₁ c₂) :=
Mbar_le.hom_of_normed_group_hom'_continuous _ _ _ _ f.sup_mul_le _ _ $
begin
  intro M,
  use M,
  intros F hF j s i hi,
  rw eval_png_apply,
  simp only,
  let Φ : Mbar r' S →+ S → ℕ → ℤ := add_monoid_hom.mk' coe_fn (λ _ _, rfl),
  show apply _ i (apply _ s (Φ (∑ (i : fin m), f j i • F i))) = 0,
  simp only [add_monoid_hom.map_sum, ← gsmul_eq_smul, add_monoid_hom.map_gsmul],
  apply fintype.sum_eq_zero,
  intro k,
  simp only [add_monoid_hom.apply_apply, add_monoid_hom.coe_mk'],
  rw [hF _ _ _ hi, gsmul_zero]
end

end basic_universal_map

end breen_deligne

#lint- only unused_arguments def_lemma doc_blame

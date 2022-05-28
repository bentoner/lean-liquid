import for_mathlib.derived.Ext_lemmas
import for_mathlib.Cech.homotopy
import for_mathlib.acyclic
import for_mathlib.exact_seq4
import for_mathlib.cech

import condensed.projective_resolution
.

noncomputable theory

universes u

open category_theory category_theory.limits homotopy_category opposite
open function (surjective)

namespace condensed

def free_Cech' (F : arrow Profinite.{u}) :
  chain_complex (Condensed.{u} Ab.{u+1}) ℕ :=
(((simplicial_object.augmented.whiskering _ _).obj
  (Profinite_to_Condensed ⋙ CondensedSet_to_Condensed_Ab)).obj
  F.augmented_cech_nerve).to_complex

def free_Cech (F : arrow Profinite.{u}) :
  chain_complex (Condensed.{u} Ab.{u+1}) ℤ :=
(homological_complex.embed $ complex_shape.embedding.nat_down_int_down).obj (free_Cech' F)

lemma free_Cech_exact (F : arrow Profinite.{u}) (n : ℤ) :
  is_zero $ (free_Cech F).homology n :=
sorry

lemma free_Cech_kernel_SES (F : arrow Profinite.{u}) : ∀ n,
  short_exact (kernel.ι $ (free_Cech F).d (n+1+1) (n+1)) (delta_to_kernel _ (n+1+1) (n+1) n) :=
begin
  erw ← is_acyclic_iff_short_exact_to_cycles' (free_Cech F), exact free_Cech_exact F
end

variable (M : Condensed.{u} Ab.{u+1})

abbreviation HH (i : ℤ) (S : Profinite.{u}) (M : Condensed.{u} Ab.{u+1}) :=
((Ext' i).obj (op $ (CondensedSet_to_Condensed_Ab).obj $ Profinite.to_Condensed S)).obj M

def acyclic_of_exact.IH (n : ℤ) : Prop := ∀ S, ∀ i > 0, i ≤ n → is_zero (HH i S M)

/-- Consider the following commutative diagram
```
     O₀
     ↓
A₁ → B₁ → C₁ → O₁
   ↘ ↓
     B₂
     ↓  ↘
O₃ → B₃ → C₃
```
where `O₀`, `O₁`, and `O₃` are zero objects, and all sequence are exact.

Then `C₁` is also a zero object.
-/
lemma acyclic_of_exact.induction_step_aux {𝓐 : Type*} [category 𝓐] [abelian 𝓐]
  {O₀ O₁ O₃ A₁ B₁ C₁ B₂ B₃ C₃ : 𝓐}
  {α₁ : A₁ ⟶ B₁} {β₁ : B₁ ⟶ C₁} {γ₁ : C₁ ⟶ O₁} (ex₁ : exact_seq 𝓐 [α₁, β₁, γ₁])
  {d₁ : A₁ ⟶ B₂} {d₂ : B₂ ⟶ C₃}                 (exd : exact d₁ d₂)
  {b₀ : O₀ ⟶ B₁} {b₁ : B₁ ⟶ B₂} {b₂ : B₂ ⟶ B₃} (exb : exact_seq 𝓐 [b₀, b₁, b₂])
  {α₃ : O₃ ⟶ B₃} {β₃ : B₃ ⟶ C₃}                 (ex₃ : exact α₃ β₃)
  (hO₀ : is_zero O₀) (hO₁ : is_zero O₁) (hO₃ : is_zero O₃)
  (tr₁ : α₁ ≫ b₁ = d₁) (tr₂ : b₂ ≫ β₃ = d₂) :
  is_zero C₁ :=
begin
  refine (ex₁.drop 1).pair.is_zero_of_eq_zero_eq_zero
    (ex₁.pair.eq_zero_of_epi _) (hO₁.eq_of_tgt _ _),
  haveI : mono b₁ := exb.pair.mono_of_eq_zero (hO₀.eq_of_src _ _),
  haveI : mono β₃ := ex₃.mono_of_eq_zero (hO₃.eq_of_src _ _),
  let l' := abelian.is_limit_of_exact_of_mono _ _ (exb.drop 1).pair,
  let l := is_kernel_comp_mono l' β₃ tr₂.symm,
  obtain rfl :
    α₁ = kernel.lift _ _ exd.w ≫ (is_limit.cone_point_unique_up_to_iso (limit.is_limit _) l).hom,
  { erw [← cancel_mono b₁, category.assoc,
      is_limit.cone_point_unique_up_to_iso_hom_comp _ _ walking_parallel_pair.zero, is_limit.fac,
      fork.of_ι_π_app, tr₁] },
  apply epi_comp
end

lemma acyclic_of_exact.induction_step_ex
  (F : arrow Profinite.{u}) (surj : function.surjective F.hom)
  (h : ∀ i, is_zero (((((cosimplicial_object.augmented.whiskering _ _).obj M.val).obj
      F.augmented_cech_nerve.right_op).to_cocomplex).homology i))
  (i : ℤ) :
  exact (((Ext' 0).flip.obj M).map $ ((free_Cech F).d (i+1) i).op)
        (((Ext' 0).flip.obj M).map $ ((free_Cech F).d (i+1+1) (i+1)).op) :=
sorry

lemma acyclic_of_exact.induction_step
  (h : ∀ (F : arrow Profinite.{u}) (surj : function.surjective F.hom),
    ∀ i, is_zero (((((cosimplicial_object.augmented.whiskering _ _).obj M.val).obj
      F.augmented_cech_nerve.right_op).to_cocomplex).homology i))
  (n : ℤ) (ih : acyclic_of_exact.IH M n) :
  acyclic_of_exact.IH M (n+1) :=
begin
  intros S i h1 h2,
  rw [le_iff_eq_or_lt, or_comm, int.lt_add_one_iff] at h2,
  cases h2 with h2 h2, { exact ih S i h1 h2 },
  subst i,
  let F := arrow.mk S.projective_presentation.f,
  have hF : function.surjective F.hom,
  { rw ← Profinite.epi_iff_surjective, apply projective_presentation.epi },
  let E := λ i, (Ext' i).flip.obj M,
  have ih' : ∀ (i j : ℤ) (h0i : 0 < i) (hin : i ≤ n),
    is_zero ((E i).obj (op ((free_Cech F).X j))),
  { intros i j h0i hin,
    cases j with j j,
    { cases j; exact ih _ _ h0i hin, },
    { apply bounded_derived_category.Ext'_zero_left_is_zero,
      exact (is_zero_zero _).op, } },
  let K := λ i, kernel ((free_Cech F).d (i + 1) i),
  have LES := λ i j, (free_Cech_kernel_SES F i).Ext'_five_term_exact_seq M j,
  have H1 : ∀ i > 0, is_zero ((E i).obj (op ((free_Cech F).X 1))),
  { intros i hi,
    apply bounded_derived_category.Ext'_is_zero_of_projective _ _ _ _ hi,
    apply_with Condensed_Ab.free.category_theory.projective {instances:=ff},
    rw [simplicial_object.augmented.drop_obj, arrow.augmented_cech_nerve_left],
    apply projective.of_iso (arrow.cech_nerve_obj_0 F).symm,
    apply projective_presentation.projective, },
  have aux0 : ∀ (i : ℤ) (h0i : 0 < i+1) (H : is_zero ((E i).obj (op $ K 0))),
    is_zero ((E (i+1)).obj (op $ K (-1))),
  { intros i h0i H,
    refine is_zero_of_exact_is_zero_is_zero _ _ ((LES (-1) i).drop 2).pair H (H1 _ h0i), },
  have aux : ∀ (i j : ℤ) (h0i : 0 < i+1) (hi : i+1 ≤ n) (H : is_zero ((E i).obj (op $ K (j+1)))),
    is_zero ((E (i+1)).obj (op $ K j)),
  { intros i j h0i hi H,
    refine is_zero_of_exact_is_zero_is_zero _ _ ((LES j i).drop 2).pair H _,
    refine ih' _ _ h0i hi },
  suffices : ∀ i j, 0 < i → -1 ≤ j → i + j = n → is_zero ((E i).obj (op $ K j)),
  { refine is_zero_of_exact_is_zero_is_zero _ _ (LES (-2) (n+1)).pair _ _; clear LES,
    { apply bounded_derived_category.Ext'_zero_left_is_zero,
      refine (is_zero_of_mono (kernel.ι _) _).op, refine is_zero_zero _, },
    { refine this (n+1) (-1) h1 le_rfl _, rw [← sub_eq_add_neg, add_sub_cancel] } },
  obtain ⟨n, rfl⟩ : ∃ k, k+1 = n := ⟨n-1, sub_add_cancel _ _⟩,
  suffices : is_zero ((E 1).obj (op $ K n)),
  { intro i,
    apply int.induction_on' i 1; clear i,
    { intros j h0i hj hijn, rw [add_comm (1:ℤ), add_left_inj] at hijn, subst j, exact this },
    { intros i hi IH j hi' hj hijn,
      rw le_iff_eq_or_lt at hj, cases hj with hj hj,
      { subst j, apply aux0 _ hi', apply IH; linarith only [hi, hijn] },
      { apply aux _ _ hi' _ (IH _ _ _ _); linarith only [hi, hijn, hj], } },
    { intros i hi IH j hi', exfalso, linarith only [hi, hi'] } },
  clear aux0 aux,
  have aux := λ i, ((LES i (-1)).drop 2).pair.cons (LES i 0),
  have exd := acyclic_of_exact.induction_step_ex M F hF (h F hF) (n+1+1),
  apply acyclic_of_exact.induction_step_aux
    ((LES n 0).drop 1) exd ((aux (n+1)).extract 0 3) (aux (n+1+1)).pair; clear LES aux exd,
  { apply Ext'_is_zero_of_neg, dec_trivial },
  { obtain (rfl|hn) : n = -1 ∨ 1 ≤ n + 1,
    { rw [or_iff_not_imp_right], intro h2, linarith only [h1, h2] },
    { exact H1 _ zero_lt_one },
    { exact ih' _ _ zero_lt_one hn } },
  { apply Ext'_is_zero_of_neg, dec_trivial },
  { conv_rhs { rw [← delta_to_kernel_ι _ _ _ (n+1), op_comp, functor.map_comp] }, refl },
  { conv_rhs { rw [← delta_to_kernel_ι _ _ _ (n+1+1), op_comp, functor.map_comp] }, refl },
end

lemma acyclic_of_exact
  (h : ∀ (F : arrow Profinite.{u}) (surj : function.surjective F.hom),
    ∀ i, is_zero
    (((((cosimplicial_object.augmented.whiskering _ _).obj M.val).obj
      F.augmented_cech_nerve.right_op).to_cocomplex).homology i))
  (S : Profinite.{u}) :
  ∀ i > 0, is_zero (HH i S M)  :=
begin
  intros i hi,
  suffices : acyclic_of_exact.IH M i,
  { apply this S i hi le_rfl, },
  apply int.induction_on' i 0; clear hi i S,
  { intros S i h1 h2, exfalso, exact h2.not_lt h1 },
  { intros k hk, apply acyclic_of_exact.induction_step M h, },
  { rintros k hk aux S i h1 h2, exfalso, linarith only [hk, h1, h2] }
end

end condensed

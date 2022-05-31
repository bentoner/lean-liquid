import category_theory.preadditive.additive_functor
import algebra.category.Module.basic
import algebra.category.Group.preadditive
import for_mathlib.is_biprod

open category_theory category_theory.limits

namespace category_theory

namespace functor

variables {𝒜 ℬ : Type*} [category 𝒜] [category ℬ]
variables [preadditive 𝒜] [preadditive ℬ]
variables (F : 𝒜 ⥤ ℬ)


lemma additive_of_map_fst_add_snd [has_binary_biproducts 𝒜]
  (h : ∀ A : 𝒜, F.map (biprod.fst + biprod.snd : A ⊞ A ⟶ A) =
    F.map biprod.fst + F.map biprod.snd) :
  F.additive :=
{ map_add' := λ A B f g,
  begin
    have : f + g = biprod.lift f g ≫ (biprod.fst + biprod.snd),
    { rw [preadditive.comp_add, biprod.lift_fst, biprod.lift_snd] },
    rw [this, F.map_comp, h, preadditive.comp_add, ← F.map_comp, ← F.map_comp,
      biprod.lift_fst, biprod.lift_snd],
  end }

noncomputable
def obj_biprod_iso (F : 𝒜 ⥤ ℬ) [F.additive]
  (A B : 𝒜) [has_binary_biproduct A B] [has_binary_biproduct (F.obj A) (F.obj B)] :
  F.obj (A ⊞ B) ≅ F.obj A ⊞ F.obj B :=
is_biprod.iso_biprod _ (F.map_is_biprod _ (biprod.is_biprod A B))

instance forget₂_additive (R : Type*) [ring R] : (forget₂ (Module R) AddCommGroup).additive :=
{ map_add' := λ M N f g, rfl }

lemma map_is_zero {X : 𝒜} [F.additive] (hX : limits.is_zero X) :
  limits.is_zero (F.obj X) :=
begin
  rw limits.is_zero.iff_id_eq_zero at hX ⊢,
  convert congr_arg (@category_theory.functor.map _ _ _ _ F _ _) hX;
  simp,
end

end functor

end category_theory

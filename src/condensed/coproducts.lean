import condensed.is_proetale_sheaf
import condensed.top_comparison

/-!
We show that passing from a profinite set to a condensed set
preserves (finite) coproducts.
-/


open category_theory
open category_theory.limits
open opposite

universe u

namespace Profinite

@[simps]
def to_Condensed_equiv (X : Profinite.{u}) (Y : CondensedSet.{u}) :
  (X.to_Condensed ⟶ Y) ≃ Y.val.obj (op X) :=
{ to_fun := λ f, f.val.app _ $ ulift.up $ 𝟙 _,
  inv_fun := λ f, Sheaf.hom.mk $
  { app := λ T g, Y.val.map (quiver.hom.op (ulift.down g)) f,
    naturality' := sorry },
  left_inv := sorry,
  right_inv := sorry }

end Profinite

namespace CondensedSet

variables {α : Type u} [fintype α] (X : α → Profinite.{u})

@[simps]
def sigma_cone : cocone (discrete.functor X ⋙ Profinite_to_Condensed) :=
{ X := (Profinite.sigma X).to_Condensed,
  ι :=
  { app := λ i, Profinite_to_Condensed.map $ Profinite.sigma.ι X i,
    naturality' := begin
      rintros i j ⟨⟨⟨⟩⟩⟩, dsimp, simp, dsimp, simp, dsimp, simp,
    end } } .

noncomputable
def val_obj_sigma_equiv (Y : CondensedSet.{u}) :
  Y.val.obj (op $ Profinite.sigma X) ≃ (Π (a : α), Y.val.obj (op $ X a)) :=
equiv.of_bijective
(λ f a, Y.val.map (Profinite.sigma.ι X a).op f)
begin
  have := Y.2,
  rw is_sheaf_iff_is_sheaf_of_type at this,
  rw Y.val.is_proetale_sheaf_of_types_tfae.out 0 4 at this,
  have key := this.1,
  exact key ⟨α⟩ X,
end

noncomputable
def is_colimit_sigma_cone : is_colimit (sigma_cone X) :=
{ desc := λ S, (Profinite.to_Condensed_equiv _ _).symm $
    (S.X.val_obj_sigma_equiv X).symm $ λ a,
    (Profinite.to_Condensed_equiv _ _) $ S.ι.app _,
  fac' := sorry,
  uniq' := sorry }

end CondensedSet

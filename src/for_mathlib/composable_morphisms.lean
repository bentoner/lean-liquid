import category_theory.limits.preserves.shapes.zero
import category_theory.abelian.homology

open category_theory category_theory.category category_theory.limits

variables {C D : Type*} [category C] [category D]

namespace category_theory

variable (C)

/- TODO : define the subcategory of complexes with 3 objects, and consider
functor to this category, etc. -/

structure composable_morphisms := {X Y Z : C} (f : X ⟶ Y) (g : Y ⟶ Z)

instance [inhabited C] : inhabited (composable_morphisms C) := ⟨⟨𝟙 default, 𝟙 default⟩⟩

variable {C}

namespace composable_morphisms

@[ext]
structure hom (S₁ S₂ : composable_morphisms C) :=
(τ₁ : S₁.X ⟶ S₂.X) (τ₂ : S₁.Y ⟶ S₂.Y) (τ₃ : S₁.Z ⟶ S₂.Z)
(comm₁₂' : S₁.f ≫ τ₂ = τ₁ ≫ S₂.f) (comm₂₃' : S₁.g ≫ τ₃ = τ₂ ≫ S₂.g)

namespace hom

restate_axiom comm₁₂'
restate_axiom comm₂₃'

attribute [reassoc] comm₁₂
attribute [reassoc] comm₂₃

local attribute [simp] comm₁₂ comm₂₃

@[simps]
def id (S : composable_morphisms C) : hom S S :=
{ τ₁ := 𝟙 _, τ₂ := 𝟙 _, τ₃ := 𝟙 _, comm₁₂' := by simp, comm₂₃' := by simp, }

instance (S : composable_morphisms C) : inhabited (hom S S) := ⟨id S⟩

@[simps]
def comp {S₁ S₂ S₃ : composable_morphisms C} (φ : hom S₁ S₂) (ψ : hom S₂ S₃) :
  hom S₁ S₃ :=
{ τ₁ := φ.τ₁ ≫ ψ.τ₁,
  τ₂ := φ.τ₂ ≫ ψ.τ₂,
  τ₃ := φ.τ₃ ≫ ψ.τ₃,
  comm₁₂' := by simp only [comm₁₂_assoc, comm₁₂, assoc],
  comm₂₃' := by simp only [comm₂₃_assoc, comm₂₃, assoc], }

end hom

instance : category (composable_morphisms C) :=
{ hom := λ S₁ S₂, hom S₁ S₂,
  id := hom.id,
  comp := λ S₁ S₂ S₃, hom.comp, }

@[simp]
lemma id_eq (S : composable_morphisms C) : 𝟙 S = hom.id S := rfl

@[simp]
lemma comp_eq {S₁ S₂ S₃ : composable_morphisms C} (φ : S₁ ⟶ S₂) (ψ : S₂ ⟶ S₃) :
  φ ≫ ψ = hom.comp φ ψ := rfl

def zero (S : composable_morphisms C) [has_zero_morphisms C] : Prop := S.f ≫ S.g = 0

namespace zero

noncomputable
def homology {S : composable_morphisms C} [abelian C] (hS : S.zero) : C := homology S.f S.g hS

end zero

end composable_morphisms

namespace functor

@[simps]
def map_composable_morphisms (F : C ⥤ D) :
  composable_morphisms C ⥤ composable_morphisms D :=
{ obj := λ S, { f := F.map S.f, g := F.map S.g, },
  map := λ S₁ S₂ φ,
  { τ₁ := F.map φ.τ₁,
    τ₂ := F.map φ.τ₂,
    τ₃ := F.map φ.τ₃,
    comm₁₂' := by { dsimp, simp only [← F.map_comp, φ.comm₁₂], },
    comm₂₃' := by { dsimp, simp only [← F.map_comp, φ.comm₂₃], }, }, }

end functor

namespace composable_morphisms

@[simps]
def apply_functor (S : composable_morphisms C) (F : C ⥤ D) := F.map_composable_morphisms.obj S

namespace zero

lemma map_functor {S : composable_morphisms C} [has_zero_morphisms C] [has_zero_morphisms D]
  (z : S.zero) (F : C ⥤ D) [F.preserves_zero_morphisms] : (S.apply_functor F).zero :=
begin
  dsimp [zero, apply_functor] at ⊢ z,
  rw [← F.map_comp, z, F.map_zero],
end

end zero

end composable_morphisms

end category_theory

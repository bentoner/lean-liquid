import algebra.homology.exact
import for_mathlib.abelian_category
import for_mathlib.exact_seq2
.

noncomputable theory

open category_theory category_theory.limits
open opposite

-- move me
namespace category_theory

variables {𝓐 : Type*} [category 𝓐] [abelian 𝓐]

lemma exact_seq.is_iso_of_zero_of_zero {A B C D : 𝓐} {f : A ⟶ B} {g : B ⟶ C} {h : C ⟶ D}
  {L : list (arrow 𝓐)} (H : exact_seq 𝓐 (f :: g :: h :: L)) (hf : f = 0) (hh : h = 0) :
  is_iso g :=
begin
  subst f, subst h,
  have : mono g, { rw [H.pair.mono_iff_eq_zero], },
  haveI : epi g, { rw [(H.drop 1).pair.epi_iff_eq_zero] },
  exact is_iso_of_mono_of_epi g,
end

lemma exact.homology_is_zero {X Y Z : 𝓐} (f : X ⟶ Y) (g : Y ⟶ Z) (hfg : exact f g) :
  is_zero (homology f g hfg.w) :=
begin
  rw preadditive.exact_iff_homology_zero at hfg,
  rcases hfg with ⟨w, ⟨e⟩⟩,
  exact is_zero_of_iso_of_zero (is_zero_zero _) e.symm,
end

lemma exact_of_homology_is_zero {X Y Z : 𝓐} {f : X ⟶ Y} {g : Y ⟶ Z} {w : f ≫ g = 0}
  (H : is_zero (homology f g w)) :
  exact f g :=
begin
  rw preadditive.exact_iff_homology_zero,
  refine ⟨w, ⟨_⟩⟩,
  exact H.iso_zero
end

lemma is_zero.exact {X Y Z : 𝓐} (hY : is_zero Y)
  (f : X ⟶ Y) (g : Y ⟶ Z) : exact f g :=
by simp only [abelian.exact_iff, hY.eq_zero_of_tgt f, hY.eq_zero_of_tgt (limits.kernel.ι g),
    limits.zero_comp, eq_self_iff_true, and_true]

lemma is_zero.homology_is_zero {X Y Z : 𝓐} (hY : is_zero Y)
  (f : X ⟶ Y) (g : Y ⟶ Z) (w : f ≫ g = 0) :
  is_zero (homology f g w) :=
exact.homology_is_zero f g $ hY.exact f g

lemma is_zero.is_iso {X Y : 𝓐} (hX : is_zero X) (hY : is_zero Y) (f : X ⟶ Y) :
  is_iso f :=
{ out := ⟨0, hX.eq_of_src _ _, hY.eq_of_tgt _ _⟩ }

lemma is_zero.op {X : 𝓐} (h : is_zero X) : is_zero (op X) :=
{ eq_zero_of_src := λ Y f, congr_arg quiver.hom.op (h.eq_zero_of_tgt f.unop),
  eq_zero_of_tgt := λ Y f, congr_arg quiver.hom.op (h.eq_zero_of_src f.unop), }

lemma is_zero.unop {X : 𝓐ᵒᵖ} (h : is_zero X) : is_zero (unop X) :=
{ eq_zero_of_src := λ Y f, congr_arg quiver.hom.unop (h.eq_zero_of_tgt f.op),
  eq_zero_of_tgt := λ Y f, congr_arg quiver.hom.unop (h.eq_zero_of_src f.op), }

@[simp] lemma is_zero_op {X : 𝓐} : is_zero (op X) ↔ is_zero X := ⟨is_zero.unop, is_zero.op⟩
@[simp] lemma is_zero_unop {X : 𝓐ᵒᵖ} : is_zero (unop X) ↔ is_zero X := ⟨is_zero.op, is_zero.unop⟩

end category_theory

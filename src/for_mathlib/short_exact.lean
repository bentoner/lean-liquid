import for_mathlib.split_exact

noncomputable theory

open category_theory category_theory.limits

variables {𝓐 : Type*} [category 𝓐] [abelian 𝓐]

-- move me
lemma exact_of_exact_image {X Y Z : 𝓐} (f : X ⟶ Y) (g : Y ⟶ Z) (h : exact f (factor_thru_image g)) :
  exact f g :=
by { rw ← limits.image.fac g, exact exact_comp_mono h }

open_locale pseudoelement

lemma exact_factor_thru_image_iff {X Y Z : 𝓐} (f : X ⟶ Y) (g : Y ⟶ Z) :
  exact f (factor_thru_image g) ↔ exact f g :=
begin
  refine ⟨exact_of_exact_image f g, λ h, abelian.pseudoelement.exact_of_pseudo_exact _ _
    ⟨λ x, abelian.pseudoelement.zero_of_map_zero (limits.image.ι g)
      (abelian.pseudoelement.pseudo_injective_of_mono _) _ _, λ y hy, _⟩⟩,
  { rw [← abelian.pseudoelement.comp_apply, limits.image.fac],
    exact (abelian.pseudoelement.pseudo_exact_of_exact h).1 x },
  { replace hy := congr_arg (limits.image.ι g) hy,
    rw [abelian.pseudoelement.apply_zero, ← abelian.pseudoelement.comp_apply,
      limits.image.fac] at hy,
    obtain ⟨a, ha ⟩ := (abelian.pseudoelement.pseudo_exact_of_exact h).2 _ hy,
    exact ⟨a, ha⟩ }
end

lemma short_exact_kernel_factor_thru_image {A B : 𝓐} (f : A ⟶ B) :
  short_exact (kernel.ι f) (factor_thru_image f) :=
begin
  refine ⟨_⟩,
  rw exact_factor_thru_image_iff,
  apply exact_kernel_ι,
end

-- SELFCONTAINED
lemma iso_of_short_exact_comp_right {X Y Z W : 𝓐} (f : X ⟶ Y) (g : Y ⟶ Z) (h : Z ⟶ W)
  (H1 : short_exact f g) (H2 : short_exact f (g ≫ h)) :
  is_iso h :=
sorry

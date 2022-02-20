/-
Copyright (c) 2022 Adam Topaz. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Adam Topaz
-/
import category_theory.abelian.exact
import category_theory.abelian.pseudoelements

/-!
The object `homology f g w`, where `w : f ≫ g = 0`, can be identified with either a
cokernel or a kernel. The isomoprhism with a cokernel is `homology_iso_cokernel_lift`, which
was obtained elsewhere. In the case of an abelian category, this file shows the isomorphism
with a kernel as well.
We use these isomorphisms to obtain the analogous api for `homology`:
- `homology.ι` is the map from `homology f g w` into the cokernel of `f`.
- `homology.π'` is the map from `kernel g` to `homology f g w`.
- `homology.desc'` constructs a morphism from `homology f g w`, when it is viewed as a cokernel.
- `homology.lift` constructs a morphism to `homology f g w`, when it is viewed as a kernel.
- Various small lemmas are proved as well, mimicking the API for (co)kernels.
With these definitions and lemmas, the isomorphisms between homology and a (co)kernel need not
be used directly.
-/

--PR #12171

open category_theory.limits
open category_theory

noncomputable theory

universes v u
variables {A : Type u} [category.{v} A] [abelian A]

variables {X Y Z : A} (f : X ⟶ Y) (g : Y ⟶ Z) (w : f ≫ g = 0)

namespace category_theory.abelian

/-- The cokernel of `kernel.lift g f w`. This is isomorphic to `homology f g w`.
  See `homology_iso_cokernel_lift`. -/
def homology_c : A :=
cokernel (kernel.lift g f w)

/-- The kernel of `cokernel.desc f g w`. This is isomorphic to `homology f g w`.
  See `homology_iso_kernel_desc`. -/
def homology_k : A :=
kernel (cokernel.desc f g w)

/-- The canonical map from `homology_c` to `homology_k`.
  This is an isomoprhism, and it is used in obtaining the API for `homology f g w`
  in the bottom of this file. -/
def homology_c_to_k : homology_c f g w ⟶ homology_k f g w :=
cokernel.desc _ (kernel.lift _ (kernel.ι _ ≫ cokernel.π _) (by simp)) begin
  apply limits.equalizer.hom_ext,
  simp,
end

local attribute [instance] pseudoelement.hom_to_fun pseudoelement.has_zero

instance : mono (homology_c_to_k f g w) :=
begin
  apply pseudoelement.mono_of_zero_of_map_zero,
  dsimp [homology_c, homology_c_to_k],
  intros a ha,
  obtain ⟨a,rfl⟩ := pseudoelement.pseudo_surjective_of_epi (cokernel.π (kernel.lift g f w)) a,
  apply_fun (kernel.ι (cokernel.desc f g w)) at ha,
  simp only [←pseudoelement.comp_apply, cokernel.π_desc,
    kernel.lift_ι, pseudoelement.apply_zero] at ha,
  simp only [pseudoelement.comp_apply] at ha,
  haveI : exact f (cokernel.π f) := exact_cokernel f,
  obtain ⟨b,hb⟩ : ∃ b, f b = _ := pseudoelement.pseudo_exact_of_exact.2 _ ha,
  suffices : ∃ c, kernel.lift g f w c = a,
  { obtain ⟨c,rfl⟩ := this,
    simp [← pseudoelement.comp_apply] },
  use b,
  apply_fun kernel.ι g,
  swap, { apply pseudoelement.pseudo_injective_of_mono },
  simpa [← pseudoelement.comp_apply]
end

instance : epi (homology_c_to_k f g w) :=
begin
  apply pseudoelement.epi_of_pseudo_surjective,
  dsimp [homology_k, homology_c, homology_c_to_k],
  intros a,
  let b := kernel.ι (cokernel.desc f g w) a,
  haveI : exact f (cokernel.π f) := exact_cokernel f,
  obtain ⟨c,hc⟩ : ∃ c, cokernel.π f c = b,
    apply pseudoelement.pseudo_surjective_of_epi (cokernel.π f),
  have : g c = 0,
  { dsimp [b] at hc,
    rw [(show g = cokernel.π f ≫ cokernel.desc f g w, by simp), pseudoelement.comp_apply, hc],
    simp [← pseudoelement.comp_apply] },
  obtain ⟨d,hd⟩ : ∃ d, kernel.ι g d = c,
  { apply pseudoelement.pseudo_exact_of_exact.2 _ this,
    apply exact_kernel_ι },
  use cokernel.π (kernel.lift g f w) d,
  apply_fun kernel.ι (cokernel.desc f g w),
  swap, { apply pseudoelement.pseudo_injective_of_mono },
  simp only [←pseudoelement.comp_apply, cokernel.π_desc, kernel.lift_ι],
  simp only [pseudoelement.comp_apply, hd, hc],
end

instance (w : f ≫ g = 0) : is_iso (homology_c_to_k f g w) := is_iso_of_mono_of_epi _

end category_theory.abelian

/-- The homology associated to `f` and `g` is isomorphic to a kernel. -/
def homology_iso_kernel_desc : homology f g w ≅ kernel (cokernel.desc f g w) :=
homology_iso_cokernel_lift _ _ _ ≪≫ as_iso (category_theory.abelian.homology_c_to_k _ _ _)

namespace homology

-- `homology.π` is taken
/-- The canonical map from the kernel of `g` to the homology of `f` and `g`. -/
def π' : kernel g ⟶ homology f g w :=
cokernel.π _ ≫ (homology_iso_cokernel_lift _ _ _).inv

/-- The canonical map from the homology of `f` and `g` to the cokernel of `f`. -/
def ι : homology f g w ⟶ cokernel f :=
(homology_iso_kernel_desc _ _ _).hom ≫ kernel.ι _

/-- Obtain a morphism from the homology, given a morphism from the kernel. -/
def desc' {W : A} (e : kernel g ⟶ W) (he : kernel.lift g f w ≫ e = 0) :
  homology f g w ⟶ W :=
(homology_iso_cokernel_lift _ _ _).hom ≫ cokernel.desc _ e he

/-- Obtain a moprhism to the homology, given a morphism to the kernel. -/
def lift {W : A} (e : W ⟶ cokernel f) (he : e ≫ cokernel.desc f g w = 0) :
  W ⟶ homology f g w :=
kernel.lift _ e he ≫ (homology_iso_kernel_desc _ _ _).inv

@[simp, reassoc]
lemma desc'_π' {W : A} (e : kernel g ⟶ W) (he : kernel.lift g f w ≫ e = 0) :
  π' f g w ≫ desc' f g w e he = e :=
by { dsimp [π', desc'], simp }

@[simp, reassoc]
lemma ι_lift {W : A} (e : W ⟶ cokernel f) (he : e ≫ cokernel.desc f g w = 0) :
  lift f g w e he ≫ ι _ _ _ = e :=
by { dsimp [ι, lift], simp }

@[simp, reassoc]
lemma condition_π' : kernel.lift g f w ≫ π' f g w = 0 :=
by { dsimp [π'], simp }

@[simp, reassoc]
lemma condition_ι : ι f g w ≫ cokernel.desc f g w = 0 :=
by { dsimp [ι], simp }

@[ext]
lemma hom_from_ext {W : A} (a b : homology f g w ⟶ W)
  (h : π' f g w ≫ a = π' f g w ≫ b) : a = b :=
begin
  dsimp [π'] at h,
  apply_fun (λ e, (homology_iso_cokernel_lift f g w).inv ≫ e),
  swap,
  { intros i j hh,
    apply_fun (λ e, (homology_iso_cokernel_lift f g w).hom ≫ e) at hh,
    simpa using hh },
  simp only [category.assoc] at h,
  exact coequalizer.hom_ext h,
end

@[ext]
lemma hom_to_ext {W : A} (a b : W ⟶ homology f g w)
  (h : a ≫ ι f g w = b ≫ ι f g w) : a = b :=
begin
  dsimp [ι] at h,
  apply_fun (λ e, e ≫ (homology_iso_kernel_desc f g w).hom),
  swap,
  { intros i j hh,
    apply_fun (λ e, e ≫ (homology_iso_kernel_desc f g w).inv) at hh,
    simpa using hh },
  simp only [← category.assoc] at h,
  exact equalizer.hom_ext h,
end

end homology

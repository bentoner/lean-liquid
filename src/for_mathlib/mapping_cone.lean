import algebra.homology.homological_complex
import category_theory.abelian.exact
import for_mathlib.homological_complex_shift
import for_mathlib.split_exact
import category_theory.triangulated.rotate
import algebra.homology.homotopy_category
import algebra.homology.additive
import for_mathlib.homological_complex_abelian

noncomputable theory

universes v u

open_locale classical

open category_theory category_theory.limits

namespace homological_complex

variables {V : Type u} [category.{v} V] [abelian V]
variables (A B C : cochain_complex V ℤ) (f : A ⟶ B) (g : B ⟶ C)

@[simp, reassoc]
lemma homotopy.comp_X_eq_to_iso {X Y : cochain_complex V ℤ} {f g : X ⟶ Y} (h : homotopy f g)
  (i : ℤ) {j k : ℤ} (e : j = k) : h.hom i j ≫ (Y.X_eq_to_iso e).hom = h.hom i k :=
by { subst e, simp }

@[simp, reassoc]
lemma homotopy.X_eq_to_iso_comp {X Y : cochain_complex V ℤ} {f g : X ⟶ Y} (h : homotopy f g)
  {i j : ℤ} (e : i = j) (k : ℤ) : (X.X_eq_to_iso e).hom ≫ h.hom j k = h.hom i k :=
by { subst e, simp }


def cone.X : ℤ → V := λ i, A.X (i + 1) ⊞ B.X i

variables {A B C}

def cone.d : Π (i j : ℤ), cone.X A B i ⟶ cone.X A B j :=
λ i j, if hij : i + 1 = j then biprod.lift
  (biprod.desc (-A.d _ _)                         0        )
  (biprod.desc (f.f _ ≫ (B.X_eq_to_iso hij).hom) (B.d _ _))
else 0

/-- The mapping cone of a morphism `f : A → B` of homological complexes. -/
def cone : cochain_complex V ℤ :=
{ X := cone.X A B,
  d := cone.d f,
  shape' := λ i j hij, dif_neg hij,
  d_comp_d' := λ i j k (hij : _ = _) (hjk : _ = _),
  begin
    substs hij hjk,
    ext; simp [cone.d],
  end }

@[simp]
lemma cone_X (i : ℤ) : (cone f).X i = (A.X (i + 1) ⊞ B.X i) := rfl

@[simp]
lemma cone_d : (cone f).d = cone.d f := rfl

def cone.in : B ⟶ cone f :=
{ f := λ i, biprod.inr,
  comm' := λ i j hij,
  begin
    dsimp [cone_d, cone.d], dsimp at hij, rw [dif_pos hij],
    ext;
    simp only [comp_zero, category.assoc, category.comp_id,
      biprod.inr_desc, biprod.inr_fst, biprod.lift_fst, biprod.inr_snd, biprod.lift_snd],
  end }

local attribute [instance] endofunctor_monoidal_category discrete.add_monoidal

def cone.out : cone f ⟶ A⟦(1 : ℤ)⟧ :=
{ f := λ i, biprod.fst,
  comm' := λ i j (hij : _ = _),
  begin
    subst hij,
    dsimp [cone_d, cone.d],
    ext; simp,
  end }

@[simps]
def cone.triangle : triangulated.triangle (cochain_complex V ℤ) :=
{ obj₁ := A,
  obj₂ := B,
  obj₃ := cone f,
  mor₁ := f,
  mor₂ := cone.in f,
  mor₃ := cone.out f }

variable (V)

@[simps]
def _root_.homotopy_category.lift_triangle :
  triangulated.triangle (cochain_complex V ℤ) ⥤
    triangulated.triangle (homotopy_category V (complex_shape.up ℤ)) :=
{ obj := λ t, triangulated.triangle.mk _
    ((homotopy_category.quotient _ _).map t.mor₁)
    ((homotopy_category.quotient _ _).map t.mor₂)
    ((homotopy_category.quotient _ _).map t.mor₃),
  map := λ t t' f,
  { hom₁ := (homotopy_category.quotient _ _).map f.hom₁,
    hom₂ := (homotopy_category.quotient _ _).map f.hom₂,
    hom₃ := (homotopy_category.quotient _ _).map f.hom₃,
    comm₁' := by { dsimp, rw [← functor.map_comp, ← functor.map_comp, f.comm₁] },
    comm₂' := by { dsimp, rw [← functor.map_comp, ← functor.map_comp, f.comm₂] },
    comm₃' := by { dsimp, rw [← functor.map_comp, ← functor.map_comp, f.comm₃] } },
  map_id' := λ X, by { ext; exact category_theory.functor.map_id _ _  },
  map_comp' := λ X Y Z f g, by { ext; exact category_theory.functor.map_comp _ _ _ } }

variable {V}

@[simps]
def cone.triangleₕ : triangulated.triangle (homotopy_category V (complex_shape.up ℤ)) :=
(homotopy_category.lift_triangle _).obj (cone.triangle f)

section cone_functorial

variables {f} {A' B' : cochain_complex V ℤ} {f' : A' ⟶ B'} {i₁ : A ⟶ A'} {i₂ : B ⟶ B'}
variables (comm : homotopy (f ≫ i₂) (i₁ ≫ f'))

include comm

def cone.map : cone f ⟶ cone f' :=
{ f := λ i, biprod.lift
  (biprod.desc (i₁.f _) 0)
  (biprod.desc (comm.hom _ _) (i₂.f _)),
  comm' := λ i j r,
  begin
    change i+1 = j at r,
    dsimp [cone_d, cone.d],
    simp_rw dif_pos r,
    apply category_theory.limits.biprod.hom_ext;
      simp only [biprod.lift_desc, add_zero, preadditive.comp_neg, category.assoc,
        comp_zero, biprod.lift_fst, biprod.lift_snd]; ext,
    { simp },
    { simp },
    { simp only [X_eq_to_iso_f, preadditive.comp_add, biprod.inl_desc_assoc, category.assoc,
        preadditive.neg_comp],
      have := comm.comm (i+1),
      dsimp at this,
      rw [reassoc_of this],
      subst r,
      simpa [prev_d, d_next, ← add_assoc] using add_comm _ _ },
    { simp }
  end }

@[simp, reassoc]
lemma cone.in_map : cone.in f ≫ cone.map comm = i₂ ≫ cone.in f' :=
by ext; { dsimp [cone.map, cone.in], simp }

@[simp, reassoc]
lemma cone.map_out : cone.map comm ≫ cone.out f' = cone.out f ≫ i₁⟦(1 : ℤ)⟧' :=
by ext; { dsimp [cone.map, cone.out], simp }

omit comm

-- I suppose this is not true?
-- def cone.map_homotopy_of_homotopy' (comm' : homotopy (f ≫ i₂) (i₁ ≫ f')) :
--   homotopy (cone.map comm) (cone.map comm') := by admit

@[simps]
def cone.triangleₕ_map : cone.triangleₕ f ⟶ cone.triangleₕ f' :=
{ hom₁ := (homotopy_category.quotient _ _).map i₁,
  hom₂ := (homotopy_category.quotient _ _).map i₂,
  hom₃ := (homotopy_category.quotient _ _).map $ cone.map comm,
  comm₁' := by { dsimp [cone.triangleₕ], simp_rw ← functor.map_comp,
    exact homotopy_category.eq_of_homotopy _ _ comm },
  comm₂' := by { dsimp [cone.triangleₕ], simp_rw ← functor.map_comp, simp },
  comm₃' := by { dsimp [cone.triangleₕ], simp_rw ← functor.map_comp, simp } }

@[simps]
def cone.triangle_map (h : f ≫ i₂ = i₁ ≫ f') : cone.triangle f ⟶ cone.triangle f' :=
{ hom₁ := i₁,
  hom₂ := i₂,
  hom₃ := cone.map (homotopy.of_eq h),
  comm₁' := by simpa [cone.triangle],
  comm₂' := by { dsimp [cone.triangle], simp },
  comm₃' := by { dsimp [cone.triangle], simp } }

@[simp]
lemma cone.map_id (f : A ⟶ B) :
  cone.map (homotopy.of_eq $ (category.comp_id f).trans (category.id_comp f).symm) = 𝟙 _ :=
by { ext; dsimp [cone.map, cone, cone.X]; simp }

@[simp]
lemma cone.triangle_map_id (f : A ⟶ B) :
  cone.triangle_map ((category.comp_id f).trans (category.id_comp f).symm) = 𝟙 _ :=
by { ext; dsimp [cone.map, cone, cone.X]; simp }


def cone.triangle_functorial :
  arrow (cochain_complex V ℤ) ⥤ triangulated.triangle (cochain_complex V ℤ) :=
{ obj := λ f, cone.triangle f.hom,
  map := λ f g c, cone.triangle_map c.w.symm,
  map_id' := λ X, cone.triangle_map_id _,
  map_comp' := λ X Y Z f g, by { ext; dsimp [cone.map, cone, cone.X]; simp } }

-- I suppose this is also not true?
-- def cone.triangleₕ_functorial :
--   arrow (homotopy_category V (complex_shape.up ℤ)) ⥤
--     triangulated.triangle (homotopy_category V (complex_shape.up ℤ)) :=
-- { obj := λ f, cone.triangleₕ f.hom.out,
--   map := λ f g c, @cone.triangleₕ_map _ _ _ _ _ _ _ _ _ c.left.out c.right.out
--   begin
--     refine homotopy_category.homotopy_of_eq _ _ _,
--     simpa [-arrow.w] using c.w.symm
--   end,
--   map_id' := by admit,
--   map_comp' := sorry }

open_locale zero_object

instance : has_zero_object (cochain_complex V ℤ) := infer_instance

def cone_from_zero (A : cochain_complex V ℤ) : cone (0 : 0 ⟶ A) ≅ A :=
{ hom :=
  { f := λ i, biprod.snd, comm' := by { introv r, ext, dsimp [cone.d] at *, simp [if_pos r] } },
  inv := cone.in _,
  inv_hom_id' := by { intros, ext, dsimp [cone.in], simp } }

def cone_to_zero (A : cochain_complex V ℤ) : cone (0 : A ⟶ 0) ≅ A⟦(1 : ℤ)⟧ :=
{ hom := cone.out _,
  inv :=
    { f := λ i, biprod.inl, comm' := by { introv r, ext, dsimp [cone.d] at *, simp [if_pos r] } },
  hom_inv_id' := by { intros, ext, dsimp [cone.out], simp },
  inv_hom_id' := by { intros, ext, dsimp [cone.out], simp } }

def cone.desc_of_null_homotopic (h : homotopy (f ≫ g) 0) : cone f ⟶ C :=
cone.map (h.trans (homotopy.of_eq (comp_zero.symm : 0 = 0 ≫ 0))) ≫ (cone_from_zero _).hom

def cone.lift_of_null_homotopic (h : homotopy (f ≫ g) 0) : A ⟶ cone g⟦(-1 : ℤ)⟧ :=
(shift_shift_neg A (1 : ℤ)).inv ≫ (shift_functor _ (-1 : ℤ)).map ((cone_to_zero _).inv ≫
  cone.map (h.trans (homotopy.of_eq (comp_zero.symm : 0 = 0 ≫ 0))).symm)

@[simps]
def of_termwise_split_mono [H : ∀ i, split_mono (f.f i)] : B ⟶ B' :=
{ f := λ i, i₂.f i - (H i).retraction ≫ comm.hom i (i-1) ≫ B'.d (i-1) i -
    B.d i (i+1) ≫ (H (i+1)).retraction ≫ comm.hom (i+1) i,
  comm' := λ i j (r : i + 1 = j), by { subst r, simp only [d_comp_d, sub_zero, category.assoc,
    comp_zero, preadditive.comp_sub, hom.comm, preadditive.sub_comp, zero_comp, sub_right_inj,
    d_comp_d_assoc], congr; ring } }

@[simp, reassoc]
lemma of_termwise_split_mono_commutes [H : ∀ i, split_mono (f.f i)] :
  f ≫ of_termwise_split_mono comm = i₁ ≫ f' :=
begin
  ext i,
  dsimp,
  have : f.f i ≫ i₂.f i = A.d i (i + 1) ≫ comm.hom (i + 1) i + comm.hom i (i - 1) ≫
    B'.d (i - 1) i + i₁.f i ≫ f'.f i := by simpa [d_next, prev_d] using comm.comm i,
  simp only [hom.comm_assoc, preadditive.comp_sub, this],
  erw [split_mono.id_assoc, split_mono.id_assoc],
  simp [add_right_comm]
end

def of_termwise_split_mono_homotopy [H : ∀ i, split_mono (f.f i)] :
  homotopy i₂ (of_termwise_split_mono comm)  :=
{ hom := λ i j, (H i).retraction ≫ comm.hom i j,
  zero' := λ _ _ r, by rw [comm.zero _ _ r, comp_zero],
  comm := λ i,
    by { simp [d_next, prev_d], abel } }

@[simps]
def of_termwise_split_epi [H : ∀ i, split_epi (f'.f i)] : A ⟶ A' :=
{ f := λ i, i₁.f i + comm.hom i (i-1) ≫ (H (i-1)).section_ ≫ A'.d (i-1) i +
    A.d i (i+1) ≫ comm.hom (i+1) i ≫ (H i).section_,
  comm' := λ i j (r : i + 1 = j), by { subst r, simp only [add_zero, d_comp_d, preadditive.comp_add,
    category.assoc, comp_zero, add_right_inj, hom.comm, zero_comp, preadditive.add_comp,
    d_comp_d_assoc], congr; ring } }

@[simp, reassoc]
lemma of_termwise_split_epi_commutes [H : ∀ i, split_epi (f'.f i)] :
  of_termwise_split_epi comm ≫ f' = f ≫ i₂ :=
begin
  ext i,
  dsimp,
  have : f.f i ≫ i₂.f i = A.d i (i + 1) ≫ comm.hom (i + 1) i + comm.hom i (i - 1) ≫
    B'.d (i - 1) i + i₁.f i ≫ f'.f i := by simpa [d_next, prev_d] using comm.comm i,
  simp only [this, category.assoc, preadditive.add_comp, ← f'.comm],
  erw [split_epi.id, split_epi.id_assoc],
  rw [add_comm, add_comm (i₁.f i ≫ f'.f i), ← add_assoc, category.comp_id]
end

def of_termwise_split_epi_homotopy [H : ∀ i, split_epi (f'.f i)] :
  homotopy (of_termwise_split_epi comm) i₁ :=
{ hom := λ i j, comm.hom i j ≫ (H j).section_,
  zero' := λ _ _ r, by rw [comm.zero _ _ r, zero_comp],
  comm := λ i,
    by { simp [d_next, prev_d], abel } }

end cone_functorial

section termwise_split_mono_lift

@[simps]
def termwise_split_mono_lift (f : A ⟶ B) : A ⟶ biproduct B (cone (𝟙 A)) :=
biproduct.lift f (cone.in _)

@[simps]
def termwise_split_mono_desc (f : A ⟶ B) : biproduct B (cone (𝟙 A)) ⟶ B :=
biproduct.fst

@[simps]
def termwise_split_mono_section (f : A ⟶ B) : B ⟶ biproduct B (cone (𝟙 A)) :=
biproduct.inl

@[simp, reassoc] lemma termwise_split_mono_section_desc (f : A ⟶ B) :
  termwise_split_mono_section f ≫ termwise_split_mono_desc f = 𝟙 _ :=
by { ext, simp }
.
lemma termwise_split_mono_desc_section_aux (i : ℤ) :
  𝟙 (B.X i ⊞ (A.X (i + 1) ⊞ A.X i)) = biprod.snd ≫ biprod.desc (𝟙 (A.X (i + 1))) (A.d i (i + 1)) ≫
    biprod.inl ≫ biprod.inr + biprod.snd ≫ biprod.snd ≫
    (X_eq_to_iso A (sub_add_cancel i 1).symm).hom ≫ biprod.inl ≫ biprod.lift
    (biprod.desc (-A.d (i - 1 + 1) (i + 1)) 0) (biprod.desc (X_eq_to_iso A (sub_add_cancel i 1)).hom
    (A.d (i - 1) i)) ≫ biprod.inr + biprod.fst ≫ biprod.inl :=
begin
  ext1; simp only [zero_comp, preadditive.comp_add, zero_add, add_zero, biprod.inr_fst_assoc,
    biprod.inl_fst_assoc, biprod.inl_snd_assoc, biprod.inr_snd_assoc, category.comp_id],
  ext1, { simp },
  ext1, { simp only [add_zero, preadditive.add_comp, comp_zero, biprod.inr_fst, category.assoc] },
  ext1; simp,
end
.
def termwise_split_mono_desc_section (f : A ⟶ B) :
  homotopy (𝟙 _) (termwise_split_mono_desc f ≫ termwise_split_mono_section f) :=
{ hom := λ i j, if h : i = j + 1 then
    biprod.snd ≫ biprod.snd ≫ (A.X_eq_to_iso h).hom ≫ biprod.inl ≫ biprod.inr else 0,
  zero' := λ i j r, dif_neg (ne.symm r),
  comm := λ i, by { dsimp,
    simpa [d_next, prev_d, cone.d] using termwise_split_mono_desc_section_aux i } }

instance (f : A ⟶ B) (i : ℤ) : split_mono ((termwise_split_mono_lift f).f i) :=
{ retraction := biprod.snd ≫ biprod.snd, id' := by simp [cone.in] }

-- generalize to epi
@[simp]
def termwise_split_mono_lift_desc (f : A ⟶ B) :
  termwise_split_mono_lift f ≫ termwise_split_mono_desc f = f :=
by { ext, simp }

/-- We will prove this is iso later -/
def from_termwise_split_mono_lift_triangleₕ :
  cone.triangleₕ (termwise_split_mono_lift f) ⟶ cone.triangleₕ f :=
cone.triangleₕ_map
  (homotopy.of_eq ((termwise_split_mono_lift_desc f).trans (category.id_comp f).symm))

@[simps]
def termwise_split_mono_factor_homotopy_equiv : homotopy_equiv (biproduct B (cone (𝟙 A))) B :=
{ hom := termwise_split_mono_desc f,
  inv := termwise_split_mono_section f,
  homotopy_hom_inv_id := (termwise_split_mono_desc_section f).symm,
  homotopy_inv_hom_id := homotopy.of_eq (termwise_split_mono_section_desc f) }

end termwise_split_mono_lift

section termwise_split_epi_lift

@[simps]
def termwise_split_epi_lift (f : A ⟶ B) : A ⟶ biproduct A (cone (𝟙 (B⟦(-1 : ℤ)⟧))) :=
biproduct.inl

@[simps]
def termwise_split_epi_desc (f : A ⟶ B) : biproduct A (cone (𝟙 (B⟦(-1 : ℤ)⟧))) ⟶ B :=
biproduct.desc f (cone.out _ ≫ (shift_neg_shift _ _).hom)

@[simps]
def termwise_split_epi_retraction (f : A ⟶ B) : biproduct A (cone (𝟙 (B⟦(-1 : ℤ)⟧))) ⟶ A :=
biproduct.fst

@[simp, reassoc] lemma termwise_split_epi_lift_retraction (f : A ⟶ B) :
  termwise_split_epi_lift f ≫ termwise_split_epi_retraction f = 𝟙 _ :=
by { ext, simp }

@[simp]
lemma X_eq_to_iso_shift (n i j : ℤ) (h : i = j) :
  X_eq_to_iso (A⟦n⟧) h = A.X_eq_to_iso (congr_arg _ h) := rfl

lemma termwise_split_epi_retraction_lift_aux (i : ℤ) :
  𝟙 (A.X i ⊞ (B.X (i + 1 - 1) ⊞ B.X (i - 1))) = biprod.snd ≫ biprod.desc (𝟙 _)
  (-B.d (i + -1) (i + 1 + -1)) ≫ 𝟙 _ ≫ biprod.inl ≫ biprod.inr + biprod.snd ≫ biprod.snd ≫
  ((B⟦(-1 : ℤ)⟧).X_eq_to_iso (sub_add_cancel _ _).symm).hom ≫ biprod.inl ≫ biprod.lift
  (biprod.desc (B.d (i - 1 + 1 + -1) (i + 1 + -1)) 0) (biprod.desc
  ((B⟦(-1 : ℤ)⟧).X_eq_to_iso $ sub_add_cancel _ _).hom (-B.d (i - 1 + -1) (i + -1))) ≫
  biprod.inr + biprod.fst ≫ biprod.inl :=
begin
  ext1; simp only [category.comp_id, add_zero, category.id_comp, preadditive.comp_add,
    biprod.inl_snd_assoc, zero_add, zero_comp, biprod.inl_fst_assoc, biprod.inr_fst_assoc,
    biprod.inr_snd_assoc],
  ext1, { simp },
  simp only [biprod.inr_desc_assoc, preadditive.neg_comp_assoc, X_eq_to_iso_shift,
    biprod.inr_snd_assoc, preadditive.comp_add, category.assoc, preadditive.neg_comp],
  ext1, { simp only [add_zero, preadditive.add_comp, comp_zero,
    preadditive.neg_comp, biprod.inr_fst, neg_zero, category.assoc] },
  ext; simp; refl
end

def termwise_split_epi_retraction_lift (f : A ⟶ B) :
  homotopy (𝟙 _) (termwise_split_epi_retraction f ≫ termwise_split_epi_lift f) :=
{ hom := λ i j, if h : i = j + 1 then
    biprod.snd ≫ biprod.snd ≫ ((B⟦(-1 : ℤ)⟧).X_eq_to_iso h).hom ≫ biprod.inl ≫ biprod.inr else 0,
  zero' := λ i j r, dif_neg (ne.symm r),
  comm := λ i, by { dsimp,
    simpa [d_next, prev_d, cone.d] using termwise_split_epi_retraction_lift_aux i } }

instance (f : A ⟶ B) (i : ℤ) : split_epi ((termwise_split_epi_desc f).f i) :=
{ section_ := (B.X_eq_to_iso $ eq_add_neg_of_add_eq rfl).hom ≫ biprod.inl ≫ biprod.inr,
  id' := by { dsimp, simp [cone.out], dsimp, simp } }

end termwise_split_epi_lift

section termwise_split_exact

variables (f g)

/--- **WARNING** this sign is different from stacks -/
@[simps]
def connecting_hom (h : ∀ (i : ℤ), splitting (f.f i) (g.f i)) : C ⟶ A⟦(1 : ℤ)⟧ :=
{ f := λ i, (h i).section ≫ B.d i (i + 1) ≫ (h (i + 1)).retraction,
  comm' :=
  begin
    intros i j r,
    induction r,
    dsimp,
    rw ← cancel_mono (𝟙 _),
    swap, apply_instance,
    conv_lhs { rw ← (h _).ι_retraction },
    simp only [preadditive.comp_neg, one_zsmul, category.assoc, neg_smul, preadditive.neg_comp,
      ← f.comm_assoc, (h _).retraction_ι_eq_id_sub_assoc, preadditive.sub_comp_assoc,
      preadditive.sub_comp, preadditive.comp_sub, category.id_comp, d_comp_d_assoc,
      zero_comp, comp_zero, ← g.comm_assoc, (h i).section_π_assoc],
    simp,
  end }
.
@[simps]
def triangle_of_termwise_split (h : ∀ (i : ℤ), splitting (f.f i) (g.f i)) :
  triangulated.triangle (cochain_complex V ℤ) :=
triangulated.triangle.mk _ f g (connecting_hom f g h)

@[simps]
def triangleₕ_of_termwise_split (h : ∀ (i : ℤ), splitting (f.f i) (g.f i)) :
  triangulated.triangle (homotopy_category V (complex_shape.up ℤ)) :=
(homotopy_category.lift_triangle V).obj (triangle_of_termwise_split f g h)
.

@[simps]
def homotopy_connecting_hom_of_splittings (h h' : ∀ (i : ℤ), splitting (f.f i) (g.f i)) :
  homotopy (connecting_hom f g h) (connecting_hom f g h') :=
{ hom := λ i j, if e : j + 1 = i then
    ((h' i).section ≫ (h i).retraction ≫ (A.X_eq_to_iso e).inv) else 0,
  comm := λ i, by { rw ← cancel_epi (g.f _),
    dsimp, simp [d_next, prev_d, splitting.π_section_eq_id_sub_assoc], abel, exact (h i).epi },
  zero' := λ _ _ h, dif_neg h }

@[simps]
def triangleₕ_map_splittings_hom (h h' : ∀ (i : ℤ), splitting (f.f i) (g.f i)) :
  triangleₕ_of_termwise_split f g h ⟶ triangleₕ_of_termwise_split f g h' :=
{ hom₁ := 𝟙 _,
  hom₂ := 𝟙 _,
  hom₃ := 𝟙 _,
  comm₃' :=
  begin
    simp only [category.comp_id, triangleₕ_of_termwise_split_mor₃, category.id_comp,
      category_theory.functor.map_id],
    apply homotopy_category.eq_of_homotopy,
    exact homotopy_connecting_hom_of_splittings f g h h'
  end }

@[simps]
def triangleₕ_map_splittings_iso (h h' : ∀ (i : ℤ), splitting (f.f i) (g.f i)) :
  triangleₕ_of_termwise_split f g h ≅ triangleₕ_of_termwise_split f g h' :=
{ hom := triangleₕ_map_splittings_hom f g h h', inv := triangleₕ_map_splittings_hom f g h' h }

end termwise_split_exact

-- move these
lemma split_mono_of_splitting {C : Type*} [category C] [abelian C] {X Y Z : C} {f : X ⟶ Y} {g : Y ⟶ Z}
  (h : splitting f g) : split_mono f := ⟨h.retraction, by simp⟩

lemma split_epi_of_splitting {C : Type*} [category C] [abelian C] {X Y Z : C} {f : X ⟶ Y} {g : Y ⟶ Z}
  (h : splitting f g) : split_epi g := ⟨h.section, by simp⟩

section

variables {B'' B' : cochain_complex V ℤ} {b' : B'' ⟶ B} {b : B ⟶ B'}
variables (H₂ : ∀ i, splitting (f.f i) (g.f i))
variables (h₂ : homotopy (b' ≫ g) 0) (h₃ : homotopy (f ≫ b) 0)

include H₂ h₂ h₃

/--
If `A ⟶ B ⟶ C` is split exact, and `b ≫ g` and `f ≫ b'` are null-homotopic,
then so is `b' ≫ b`.

        B''
        ∣
        b'
        ↓
A - f → B - g → C
        ∣
        b
        ↓
        B'
-/
def comp_null_homotopic_of_row_split_exact : homotopy (b' ≫ b) 0 :=
begin
  haveI := λ i, split_epi_of_splitting (H₂ i),
  haveI := λ i, split_mono_of_splitting (H₂ i),
  haveI := λ i, (H₂ i).short_exact.3,
  let h₁' := (h₂.trans (homotopy.of_eq (comp_zero : 𝟙 _ ≫ 0 = 0).symm)).symm,
  let h₂' := (h₃.trans $ homotopy.of_eq (zero_comp : 0 ≫ 𝟙 _ = 0).symm),
  refine ((of_termwise_split_epi_homotopy h₁').symm.comp
    (of_termwise_split_mono_homotopy h₂')).trans (homotopy.of_eq _),
  ext i,
  exact comp_eq_zero_of_exact (f.f i) (g.f i)
    (congr_f ((of_termwise_split_epi_commutes h₁').trans comp_zero) i)
    (congr_f ((of_termwise_split_mono_commutes h₂').trans zero_comp) i)
end

end

def cone.termwise_split (i : ℤ) : splitting ((cone.in f).f i) ((cone.out f).f i) :=
{ iso := biprod.braiding _ _,
  comp_iso_eq_inl := by ext; simp [cone.in],
  iso_comp_snd_eq := by ext; simp [cone.out] }
.

def cone_homotopy_equiv_aux (c : cone f ⟶ cone f) (h₁ : homotopy (cone.in f ≫ c) (cone.in f))
  (h₂ : homotopy (c ≫ cone.out f) (cone.out f)) : homotopy (𝟙 _) (2 • c - c ≫ c) :=
begin
  have : homotopy ((𝟙 _ - c) ≫ (𝟙 _ - c)) 0,
  { apply comp_null_homotopic_of_row_split_exact (cone.in f) (cone.out f) (cone.termwise_split f),
    { refine (homotopy.of_eq _).trans h₂.symm.equiv_sub_zero, simp },
    { refine (homotopy.of_eq _).trans h₁.symm.equiv_sub_zero, simp } },
  apply homotopy.equiv_sub_zero.symm _,
  refine (homotopy.of_eq _).trans this,
  simp, abel,
end

local attribute [simp] preadditive.comp_nsmul preadditive.nsmul_comp

/--
If the following diagram commutes up to homotopy, then `c` is a homotopy equivalence
A - f → B ⟶ C(f) ⟶ A⟦1⟧
|       |      ∣       ∣
𝟙       𝟙      c       𝟙
↓       ↓      ∣       ∣
A - f → B ⟶ C(f) ⟶ A⟦1⟧
-/
def cone_homotopy_equiv (c : cone f ⟶ cone f) (h₁ : homotopy (cone.in f ≫ c) (cone.in f))
  (h₂ : homotopy (c ≫ cone.out f) (cone.out f)) : homotopy_equiv (cone f) (cone f) :=
{ hom := c,
  inv := ((2 • 𝟙 _) - c),
  homotopy_hom_inv_id := (homotopy.of_eq (by simp)).trans (cone_homotopy_equiv_aux f c h₁ h₂).symm,
  homotopy_inv_hom_id := (homotopy.of_eq (by simp)).trans (cone_homotopy_equiv_aux f c h₁ h₂).symm }
.
-- move this
instance {ι : Type*} (c : complex_shape ι) : full (homotopy_category.quotient V c) :=
by { delta homotopy_category.quotient, apply_instance }

local notation `Q` := homotopy_category.quotient V (complex_shape.up ℤ)

lemma cone_triangleₕ_map_iso_of_id (φ : cone.triangleₕ f ⟶ cone.triangleₕ f)
  (h₁ : φ.hom₁ = 𝟙 _) (h₂ : φ.hom₂ = 𝟙 _) : is_iso φ.hom₃ :=
begin
  have e₂ := φ.comm₂,
  have e₃ := φ.comm₃,
  rw [h₂, category.id_comp] at e₂,
  rw [h₁, category_theory.functor.map_id, category.comp_id] at e₃,
  erw [← Q .image_preimage φ.hom₃, ← Q .map_comp] at e₂ e₃,
  convert is_iso.of_iso (homotopy_category.iso_of_homotopy_equiv
    (cone_homotopy_equiv _ _ (homotopy_category.homotopy_of_eq _ _ e₂)
    (homotopy_category.homotopy_of_eq _ _ e₃.symm))),
  exact (Q .image_preimage _).symm
end

section

open category_theory.triangulated.triangle_morphism
-- move this
lemma triangle_morphism_is_iso {C : Type*} [category C] [has_shift C ℤ]
  {X Y : triangulated.triangle C} (f : X ⟶ Y) [is_iso f.hom₁] [is_iso f.hom₂] [is_iso f.hom₃] :
  is_iso f :=
by { refine ⟨⟨⟨inv f.hom₁, inv f.hom₂, inv f.hom₃, _, _, _⟩, _, _⟩⟩; tidy }
.
instance {C : Type*} [category C] [has_shift C ℤ] {X Y : triangulated.triangle C} (f : X ⟶ Y)
  [is_iso f] : is_iso f.hom₁ :=
by { refine ⟨⟨(inv f).hom₁, _, _⟩⟩; simpa only [← comp_hom₁, ← triangulated.triangle_category_comp,
  is_iso.hom_inv_id, is_iso.inv_hom_id] }

instance {C : Type*} [category C] [has_shift C ℤ] {X Y : triangulated.triangle C} (f : X ⟶ Y)
  [is_iso f] : is_iso f.hom₂ :=
by { refine ⟨⟨(inv f).hom₂, _, _⟩⟩; simpa only [← comp_hom₂, ← triangulated.triangle_category_comp,
  is_iso.hom_inv_id, is_iso.inv_hom_id] }

instance {C : Type*} [category C] [has_shift C ℤ] {X Y : triangulated.triangle C} (f : X ⟶ Y)
  [is_iso f] : is_iso f.hom₃ :=
by { refine ⟨⟨(inv f).hom₃, _, _⟩⟩; simpa only [← comp_hom₃, ← triangulated.triangle_category_comp,
  is_iso.hom_inv_id, is_iso.inv_hom_id] }

lemma triangle_morphism_is_iso_iff {C : Type*} [category C] [has_shift C ℤ]
  {X Y : triangulated.triangle C} (f : X ⟶ Y) : is_iso f ↔
    is_iso f.hom₁ ∧ is_iso f.hom₂ ∧ is_iso f.hom₃ :=
begin
  split,
  { intro _, refine ⟨_, _, _⟩; exactI infer_instance },
  { rintro ⟨_, _, _⟩, exactI triangle_morphism_is_iso f }
end

end

lemma cone.triangleₕ_is_iso {A' B' : cochain_complex V ℤ} {f : A ⟶ B} {f' : A' ⟶ B'}
  (φ : cone.triangleₕ f ⟶ cone.triangleₕ f') [is_iso φ.hom₁] [is_iso φ.hom₂] : is_iso φ :=
begin
  suffices : is_iso φ.hom₃,
  { exactI triangle_morphism_is_iso _ },
  have := φ.comm₁,
  dsimp at this,
  rw [← is_iso.eq_comp_inv, category.assoc, ← is_iso.inv_comp_eq,
    ← Q .image_preimage (inv φ.hom₁), ← Q .map_comp,
    ← Q .image_preimage (inv φ.hom₂), ← Q .map_comp] at this,
  let T := cone.triangleₕ_map (homotopy_category.homotopy_of_eq _ _ this).symm,
  haveI := cone_triangleₕ_map_iso_of_id _ (φ ≫ T) (by simp) (by simp),
  haveI := cone_triangleₕ_map_iso_of_id _ (T ≫ φ) (by simp) (by simp),
  haveI : epi φ.hom₃ := @@epi_of_epi _ (T.hom₃) (φ.hom₃) (show epi (T ≫ φ).hom₃, by apply_instance),
  use T.hom₃ ≫ inv (φ ≫ T).hom₃,
  split,
  { rw ← category.assoc, exact is_iso.hom_inv_id _ },
  { rw [← cancel_epi φ.hom₃, ← category.assoc, ← category.assoc, category.comp_id,
      category.assoc],
    exact is_iso.hom_inv_id_assoc (φ ≫ T).hom₃ _ }
end

instance : is_iso (from_termwise_split_mono_lift_triangleₕ f) :=
begin
  haveI : is_iso (from_termwise_split_mono_lift_triangleₕ f).hom₁,
  { delta from_termwise_split_mono_lift_triangleₕ, dsimp, apply_instance },
  haveI : is_iso (from_termwise_split_mono_lift_triangleₕ f).hom₂ :=
    is_iso.of_iso (homotopy_category.iso_of_homotopy_equiv
      (termwise_split_mono_factor_homotopy_equiv f)),
  apply cone.triangleₕ_is_iso,
end

-- move this
@[simp]
lemma cochain_complex_d_next (i : ℤ) (f : Π i j, A.X i ⟶ B.X j) :
  d_next i f = A.d i (i + 1) ≫ f (i + 1) i :=
by simp [d_next]

@[simp]
lemma cochain_complex_prev_d (i : ℤ) (f : Π i j, A.X i ⟶ B.X j) :
  prev_d i f = f i (i - 1) ≫ B.d (i - 1) i :=
by simp [prev_d]

-- move this
section

@[simps]
def _root_.category_theory.triangulated.neg₃_functor (C : Type*) [category C] [has_shift C ℤ]
  [preadditive C] :
  triangulated.triangle C ⥤ triangulated.triangle C :=
{ obj := λ T, triangulated.triangle.mk C T.mor₁ T.mor₂ (-T.mor₃),
  map := λ S T f, { hom₁ := f.hom₁, hom₂ := f.hom₂, hom₃ := f.hom₃ } }

@[simps]
def _root_.category_theory.triangulated.neg₃_unit_iso (C : Type*) [category C] [has_shift C ℤ]
  [preadditive C] : category_theory.triangulated.neg₃_functor C ⋙
    category_theory.triangulated.neg₃_functor C ≅ 𝟭 _ :=
begin
  refine nat_iso.of_components
    (λ X, ⟨⟨𝟙 _, 𝟙 _, 𝟙 _, _, _, _⟩, ⟨𝟙 _, 𝟙 _, 𝟙 _, _, _, _⟩, _, _⟩) (λ X Y f, _),
  any_goals { ext },
  all_goals { dsimp,
    simp only [category.comp_id, category.id_comp, category_theory.functor.map_id, neg_neg] },
end
.
@[simps]
def _root_.category_theory.triangulated.neg₃_equiv (C : Type*) [category C] [has_shift C ℤ]
  [preadditive C] : triangulated.triangle C ≌ triangulated.triangle C :=
{ functor := category_theory.triangulated.neg₃_functor C,
  inverse := category_theory.triangulated.neg₃_functor C,
  unit_iso := (category_theory.triangulated.neg₃_unit_iso C).symm,
  counit_iso := category_theory.triangulated.neg₃_unit_iso C }
.
end

@[simps]
def termwise_split_to_cone (h : ∀ i, splitting (f.f i) (g.f i)) :
  C ⟶ cone f :=
{ f := λ i, biprod.lift (-(connecting_hom f g h).f i) ((h i).section),
  comm' := begin
    rintro i j (rfl : i + 1 = j),
    haveI := λ i, split_epi_of_splitting (h i),
    haveI := λ i, split_mono_of_splitting (h i),
    ext,
    { dsimp [cone.d],
      rw ← cancel_epi (g.f _),
      { simp [g.comm, splitting.π_section_eq_id_sub_assoc] },
      { apply_instance } },
    { dsimp [cone.d],
      rw ← cancel_epi (g.f _),
      { simp [splitting.π_section_eq_id_sub_assoc, splitting.π_section_eq_id_sub] },
      { apply_instance } },
  end }
.

@[simps]
def comp_termwise_split_to_cone_homotopy (h : ∀ i, splitting (f.f i) (g.f i)) :
  homotopy (g ≫ termwise_split_to_cone f g h) (cone.in f) :=
{ hom := λ i j,
    if e : j + 1 = i then -(h i).retraction ≫ (A.X_eq_to_iso e).inv ≫ biprod.inl else 0,
  zero' := λ _ _ r, dif_neg r,
  comm := λ i, begin
    dsimp,
    simp only [dite_eq_ite, cochain_complex_prev_d, dif_pos, if_true, category.assoc, cone_d,
      category.id_comp, add_left_inj, sub_add_cancel, dif_ctx_congr, X_eq_to_iso_refl, cone.d,
      preadditive.comp_neg, eq_self_iff_true, cochain_complex_d_next, preadditive.neg_comp],
    ext,
    { simp [cone.in, splitting.π_section_eq_id_sub_assoc, ← sub_eq_add_neg] },
    { simp [cone.in, splitting.retraction_ι_eq_id_sub, ← sub_eq_add_neg] },
  end }
.

-- move this
lemma _root_.category_theory.splitting.comp_eq_zero {C : Type*} [category C] [abelian C] {X Y Z : C}
  {f : X ⟶ Y} {g : Y ⟶ Z} (h : splitting f g) : f ≫ g = 0 :=
h.split.1.some_spec.some_spec.2.2.1

@[simps]
def cone_to_termwise_split (h : ∀ i, splitting (f.f i) (g.f i)) :
  cone f ⟶ C :=
{ f := λ i, biprod.snd ≫ g.f i,
  comm' := begin
    rintro i j (rfl : i + 1 = j),
    ext; simp [cone.d, (h _).comp_eq_zero],
  end }

@[simps]
def cone_to_termwise_split_comp_homotopy (h : ∀ i, splitting (f.f i) (g.f i)) :
  homotopy (cone_to_termwise_split f g h ≫ connecting_hom f g h) (-cone.out f) :=
{ hom := λ i j,
    if e : j + 1 = i then biprod.snd ≫ (h i).retraction ≫ (A.X_eq_to_iso e).inv else 0,
  zero' := λ _ _ r, dif_neg r,
  comm := begin
    intro i,
    dsimp,
    simp only [category.comp_id, dite_eq_ite, cochain_complex_prev_d, cone.out, dif_pos, if_true,
      add_left_inj, sub_add_cancel, cone.d, shift_d, dif_ctx_congr, preadditive.comp_neg,
      eq_self_iff_true, int.neg_one_pow_one, cochain_complex_d_next, one_zsmul,
      category.assoc, X_eq_to_iso_d, neg_neg, neg_smul, biprod.lift_snd_assoc,
      X_eq_to_iso_refl, cone_d, preadditive.neg_comp],
    ext; simp [splitting.π_section_eq_id_sub_assoc, sub_eq_add_neg],
  end }
.
def iso_cone_of_termwise_split_inv_hom_homotopy (h : ∀ i, splitting (f.f i) (g.f i)) :
  homotopy (cone_to_termwise_split f g h ≫ termwise_split_to_cone f g h) (𝟙 _) :=
{ hom := λ i j, if e : j + 1 = i then
    -biprod.snd ≫ (h i).retraction ≫ (A.X_eq_to_iso e).inv ≫ biprod.inl else 0,
  zero' := λ _ _ r, dif_neg r,
  comm := begin
    intro i,
    dsimp,
    simp only [category.comp_id, dite_eq_ite, cochain_complex_prev_d, dif_pos, if_true,
      category.id_comp, add_left_inj, sub_add_cancel, cone.d, dif_ctx_congr,
      eq_self_iff_true, cochain_complex_d_next, category.assoc, biprod.lift_snd_assoc,
      X_eq_to_iso_refl, cone_d],
    ext; -- This is simp [splitting.π_section_eq_id_sub_assoc, splitting.π_section_eq_id_sub]
      simp only [add_left_neg, add_zero, category.assoc, category.comp_id, exact.w, exact.w_assoc,
        biprod.inl_desc, biprod.inl_desc_assoc, biprod.inl_fst, biprod.inr_desc_assoc,
        biprod.inr_fst, biprod.inr_snd, biprod.inr_snd_assoc, biprod.lift_fst, biprod.lift_snd,
        biprod.lift_snd_assoc, comp_zero, zero_comp, preadditive.add_comp, preadditive.comp_add,
        preadditive.comp_neg, preadditive.neg_comp, preadditive.neg_comp, category.comp_id,
        splitting.ι_retraction_assoc, eq_self_iff_true, X_eq_to_iso_d, X_eq_to_iso_f_assoc,
        X_eq_to_iso_refl, X_eq_to_iso_trans, neg_neg, neg_zero, zero_add, neg_sub, hom.comm_assoc,
        splitting.π_section_eq_id_sub_assoc, splitting.π_section_eq_id_sub, category.id_comp,
        preadditive.sub_comp_assoc, hom.comm, preadditive.sub_comp, splitting.ι_retraction];
      abel
  end }
.
section

-- move & generalize this
instance homotopy_category.has_add {X Y : homotopy_category V (complex_shape.up ℤ)} :
  has_add (X ⟶ Y) :=
⟨λ f g, Q .map (Q .preimage f + Q .preimage g)⟩

@[simp]
lemma quotient_map_add {f g : A ⟶ B} : Q .map (f + g) = Q .map f + Q .map g :=
begin
  delta homotopy_category.has_add,
  apply homotopy_category.eq_of_homotopy,
  apply homotopy.add; { apply homotopy_category.homotopy_of_eq, simp },
end

instance homotopy_category.hom.add_comm_group {X Y : homotopy_category V (complex_shape.up ℤ)} :
  add_comm_group (X ⟶ Y) :=
{ zero := Q .map 0,
  neg := λ f, Q .map (- Q .preimage f),
  add_assoc := λ _ _ _, by { dsimp [homotopy_category.has_add],
    rw [quotient_map_add, functor.image_preimage, ← quotient_map_add, add_assoc], simp },
  zero_add := λ f, by { rw [← Q .image_preimage f, ← quotient_map_add, zero_add] },
  add_zero := λ f, by { rw [← Q .image_preimage f, ← quotient_map_add, add_zero] },
  add_comm := λ f g, by { rw [← Q .image_preimage f, ← Q .image_preimage g, ← quotient_map_add,
    add_comm], simp },
  add_left_neg := λ f, by { nth_rewrite 1 ← Q .image_preimage f, erw ← quotient_map_add,
    rw add_left_neg, refl },
 ..homotopy_category.has_add }
.

instance : preadditive (homotopy_category V (complex_shape.up ℤ)) :=
{ add_comp' := λ _ _ _ f g h, begin
    rw ← Q .image_preimage h,
    nth_rewrite 1 ← Q .image_preimage f,
    nth_rewrite 1 ← Q .image_preimage g,
    erw [← Q .map_comp, ← quotient_map_add],
    rw preadditive.add_comp,
  end,
  comp_add' := λ _ _ _ f g h, begin
    rw ← Q .image_preimage f,
    nth_rewrite 1 ← Q .image_preimage g,
    nth_rewrite 1 ← Q .image_preimage h,
    erw [← Q .map_comp, ← quotient_map_add],
    rw preadditive.comp_add,
  end }

instance quotient_additive : Q .additive := {}
end

@[simps]
def iso_cone_of_termwise_split (h : ∀ i, splitting (f.f i) (g.f i)) :
  triangleₕ_of_termwise_split f g h ≅
    (category_theory.triangulated.neg₃_functor _).obj (cone.triangleₕ f) :=
{ hom :=
  { hom₁ := 𝟙 _,
    hom₂ := 𝟙 _,
    hom₃ := Q .map (termwise_split_to_cone f g h),
    comm₁' := (category.comp_id _).trans (category.id_comp _).symm,
    comm₂' := by { dsimp, rw [← Q .map_comp, category.id_comp],
      apply homotopy_category.eq_of_homotopy, apply comp_termwise_split_to_cone_homotopy },
    comm₃' := by { dsimp, rw [category_theory.functor.map_id, category.comp_id,
      ← Q .map_neg, ← Q .map_comp], congr, ext, simp [cone.out] } },
  inv :=
  { hom₁ := 𝟙 _,
    hom₂ := 𝟙 _,
    hom₃ := Q .map (cone_to_termwise_split f g h),
    comm₁' := (category.comp_id _).trans (category.id_comp _).symm,
    comm₂' := by { dsimp, rw [← Q .map_comp, category.id_comp], congr, ext, simp [cone.in] },
    comm₃' := by { dsimp, rw [category_theory.functor.map_id, category.comp_id, ← Q .map_comp,
      ← Q .map_neg], symmetry, apply homotopy_category.eq_of_homotopy,
      apply cone_to_termwise_split_comp_homotopy }, },
  hom_inv_id' := by { ext, { exact category.comp_id _ }, { exact category.comp_id _ },
    dsimp, erw [← Q .map_comp, ← Q .map_id], congr, ext; dsimp, simp },
  inv_hom_id' := by { ext, { exact category.comp_id _ }, { exact category.comp_id _ },
    dsimp, erw [← Q .map_comp, ← Q .map_id], apply homotopy_category.eq_of_homotopy,
    apply iso_cone_of_termwise_split_inv_hom_homotopy } }
.
--move this
lemma mono_of_eval [∀ i, mono (f.f i)] : mono f :=
begin
  constructor,
  intros Z g h r,
  ext i,
  rw ← cancel_mono (f.f i),
  exact congr_f r i
end

instance : mono (termwise_split_mono_lift f) := mono_of_eval _

def termwise_split_of_termwise_split_mono [H : ∀ i, split_mono (f.f i)] (i : ℤ) :
  splitting (f.f i)
    ((@@homological_complex.normal_mono _ _ f (mono_of_eval _)).g.f i) :=
begin
  apply left_split.splitting, -- This uses a sorry :(
  dsimp only [normal_mono, cokernel_complex_π],
  haveI : exact (f.f i) (cokernel.π (f.f i)) := abelian.exact_cokernel _,
  constructor,
  exact ⟨(H i).1, (H i).2⟩
end

/-- Every neg₃ of a cone triangle is isomorphic to some triangle associated to some
  termwise split sequence -/
def iso_termwise_split_of_cone :
      (category_theory.triangulated.neg₃_functor _).obj (cone.triangleₕ f) ≅
    triangleₕ_of_termwise_split (termwise_split_mono_lift f)
      (homological_complex.normal_mono (termwise_split_mono_lift f)).g
    (termwise_split_of_termwise_split_mono _) :=
functor.map_iso _ (as_iso $ from_termwise_split_mono_lift_triangleₕ f).symm ≪≫
  (iso_cone_of_termwise_split _ _ _).symm
.

-- Lemma 13.9.15. skipped

def inv_rotate_iso_cone_triangle (h : ∀ i, splitting (f.f i) (g.f i)) :
  (triangle_of_termwise_split f g h).inv_rotate ≅
    cone.triangle ((connecting_hom f g h)⟦(-1 : ℤ)⟧') := sorry

end homological_complex

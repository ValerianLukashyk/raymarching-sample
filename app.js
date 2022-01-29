import * as THREE from "three";
import fragment from "./shaders/fragment.glsl"
import vertex from "./shaders/vertex.glsl"
import matcap from './1.png'
import matcap2 from './1.png'



class Scene {
  constructor() {
    this.container = document.getElementById("scene");
    this.width = window.innerWidth;
    this.height = window.innerHeight;
    this.time = 0
  
    // Orthographic camera
    const frustumSize = 1

    this.camera = new THREE.OrthographicCamera(frustumSize / -2, frustumSize / 2, frustumSize / 2, frustumSize / -2, -1000, 1000)

    this.scene = new THREE.Scene();
    this.clock = new THREE.Clock();
    this.renderer = new THREE.WebGLRenderer({
      canvas: this.container,
      antialias: true,
      alpha: true,
    });
    this.renderer.setSize(this.width, this.height);
    this.renderer.setPixelRatio(devicePixelRatio);
    this.renderer.outputEncoding = THREE.sRGBEncoding

    this.addObject();
    this.resize();
    this.setupResize();
    this.mouseEvents()
    this.render();
  }

  mouseEvents() {
    this.mouse = new THREE.Vector2()
    document.addEventListener('mousemove', (e) => {
      this.mouse.x = e.pageX / this.width - 0.5
      this.mouse.y = -e.pageY / this.height + 0.5
    })
  }

  setupResize() {
    window.addEventListener("resize", this.resize.bind(this));
  }

  resize() {
    this.width = window.innerWidth;
    this.height = window.innerHeight;

    this.camera.aspect = this.width / this.height;
    this.renderer.setSize(this.width, this.height);


    this.imageAspect = 1;
    let a1; let a2;
    if (this.height / this.width > this.imageAspect) {
      a1 = (this.width / this.height) * this.imageAspect;
      a2 = 1;
    } else {
      a1 = 1;
      a2 = (this.height / this.width) / this.imageAspect;
    }

    this.material.uniforms.resolution.value.x = this.width;
    this.material.uniforms.resolution.value.y = this.height;
    this.material.uniforms.resolution.value.z = a1;
    this.material.uniforms.resolution.value.w = a2;


    this.camera.updateProjectionMatrix();

  }

  addObject() {
    this.geometry = new THREE.PlaneGeometry(1, 1, 1, 1)

    this.material = new THREE.ShaderMaterial({
      extensions: {
        derivatives: "#extension GL_OES_standard_derivatives : enable"
      },
      side: THREE.DoubleSide,
      fragmentShader: fragment,
      vertexShader: vertex,
      uniforms: {
        time: { value: 0 },
        mouse: { value: new THREE.Vector2(0, 0) },
        resolution: { value: new THREE.Vector4() },
        matcap: { value: new THREE.TextureLoader().load(matcap) },
        matcap2: { value: new THREE.TextureLoader().load(matcap2) },
      },
    })
    this.cube = new THREE.Mesh(this.geometry, this.material)
    
    this.scene.add(this.cube)
  }

  render() {
    this.time += 0.01
    this.material.uniforms.time.value = this.time
    this.material.uniforms.mouse.value = this.mouse
    this.renderer.render(this.scene, this.camera);
    window.requestAnimationFrame(this.render.bind(this));
  }
}

new Scene();
